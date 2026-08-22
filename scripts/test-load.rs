#!/usr/bin/env rust-script
//! Load test + inventory for the Nushell module tree under `lib/`.
//!
//! Two checks, both free of side effects:
//!
//!   1. `nu-check --as-module` on every `.nu` file. This PARSES without
//!      executing, which matters here: several files are bare-pipeline scripts,
//!      so `use`-ing them would run git commands and file operations.
//!
//!   2. `use lib/<category>/mod.nu *` per category, in a subprocess — the check
//!      CLAUDE.md describes as this repo's validation story. Subprocess isolation
//!      keeps the `export-env` blocks in autojump.nu, zoxide-menu.nu, zellij.nu,
//!      magi.nu and ai/mod.nu from leaking into your shell.
//!
//! The contract comes from the `mod.nu` files themselves rather than a separate
//! expectations list, so it cannot drift: a file a category glob-re-exports MUST
//! parse as a module. Files `mod.nu` deliberately leaves out are reported but
//! never fail the run — being unloadable is often exactly why they were excluded.
//!
//! Dependency-free on purpose (no `[dependencies]` block): CI compiles it in
//! seconds and it needs no crate registry.
//!
//! Usage:
//!   ./scripts/test-load.rs                # load test + summary
//!   ./scripts/test-load.rs --inventory    # add the inventory report
//!   ./scripts/test-load.rs --quiet        # failures and summary only

use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

// ---------------------------------------------------------------- parsing --

/// Files a category's `mod.nu` glob-re-exports, e.g. `export use ./tree.nu *`.
/// Returns paths relative to the category directory.
fn globbed(mod_nu: &Path) -> Vec<String> {
    let Ok(text) = fs::read_to_string(mod_nu) else {
        return Vec::new();
    };
    let mut out = Vec::new();
    for line in text.lines() {
        let line = line.trim();
        let Some(rest) = line.strip_prefix("export use ") else {
            continue;
        };
        // Only the glob form re-exports commands; a bare `export use x.nu`
        // would expose them under a module name instead.
        let Some(path) = rest.strip_suffix(" *") else {
            continue;
        };
        let path = path.trim().trim_start_matches("./");
        if path.ends_with(".nu") {
            out.push(path.to_string());
        }
    }
    out
}

/// Command names a file exports, read statically — nothing is loaded or run.
///
/// Handles `export def`, `export extern`, `export alias`, any number of flags
/// (`--env`, `--wrapped`), and names that are bare, "double quoted", or
/// 'single quoted'.
fn exports(file: &Path) -> Vec<String> {
    let Ok(text) = fs::read_to_string(file) else {
        return Vec::new();
    };
    let mut out = Vec::new();
    for line in text.lines() {
        // Only top-level exports count. An indented `export def` sits inside an
        // inner `module` block and never escapes the file — that is precisely
        // why cdpath.nu and update-path.nu contribute nothing.
        if !line.starts_with("export ") {
            continue;
        }
        let mut words = line["export ".len()..].split_whitespace();
        match words.next() {
            Some("def") | Some("extern") | Some("alias") => {}
            _ => continue,
        }
        // Skip flags between the keyword and the name.
        let mut token = words.next();
        while matches!(token, Some(t) if t.starts_with("--")) {
            token = words.next();
        }
        let Some(token) = token else { continue };

        // Reconstruct a quoted name, which split_whitespace will have torn apart.
        let name = if let Some(q) = token.strip_prefix('"') {
            match line.split('"').nth(1) {
                Some(full) => full.to_string(),
                None => q.to_string(),
            }
        } else if let Some(q) = token.strip_prefix('\'') {
            match line.split('\'').nth(1) {
                Some(full) => full.to_string(),
                None => q.to_string(),
            }
        } else {
            token
                .split(|c| c == '(' || c == '[' || c == '{')
                .next()
                .unwrap_or(token)
                .to_string()
        };
        if !name.is_empty() {
            out.push(name);
        }
    }
    out
}

// ------------------------------------------------------------ nu subprocess --

struct Outcome {
    ok: bool,
    message: String,
}

fn squote(path: &Path) -> String {
    format!("'{}'", path.display())
}

fn tidy(s: &str) -> String {
    let joined = s.split_whitespace().collect::<Vec<_>>().join(" ");
    if joined.chars().count() > 200 {
        joined.chars().take(197).collect::<String>() + "..."
    } else {
        joined
    }
}

fn run_nu(command: &str) -> Option<(bool, String, String)> {
    let out = Command::new("nu")
        .args(["--no-config-file", "--commands", command])
        .output()
        .ok()?;
    Some((
        out.status.success(),
        String::from_utf8_lossy(&out.stdout).into_owned(),
        String::from_utf8_lossy(&out.stderr).into_owned(),
    ))
}

/// Parse a file as a module without executing it.
///
/// Plain `nu-check` prints `true`/`false` and exits 0 either way, so the bool is
/// what decides. Only on failure do we re-run with `--debug` for a message; if
/// that flag is unavailable the failure is still reported, just without detail.
fn check_module(file: &Path) -> Outcome {
    let cmd = format!("nu-check --as-module {}", squote(file));
    match run_nu(&cmd) {
        Some((success, stdout, stderr)) => {
            if success && stdout.trim() == "true" {
                return Outcome { ok: true, message: String::new() };
            }
            let detail = run_nu(&format!("nu-check --debug --as-module {}", squote(file)))
                .map(|(_, _, e)| e)
                .unwrap_or_default();
            let message = tidy(&format!("{detail} {stderr}"));
            Outcome {
                ok: false,
                message: if message.is_empty() {
                    "does not parse as a module".to_string()
                } else {
                    message
                },
            }
        }
        None => Outcome { ok: false, message: "could not run nu".to_string() },
    }
}

/// Load a module the way a user would, isolated in a subprocess.
fn check_use(target: &Path) -> Outcome {
    match run_nu(&format!("use {} *", squote(target))) {
        Some((success, _, stderr)) => Outcome { ok: success, message: tidy(&stderr) },
        None => Outcome { ok: false, message: "could not run nu".to_string() },
    }
}

// --------------------------------------------------------------------- main --

struct FileCheck {
    category: String,
    file: String,
    required: bool,
    parses: bool,
    message: String,
}

fn categories(lib: &Path) -> Vec<PathBuf> {
    let mut dirs: Vec<PathBuf> = fs::read_dir(lib)
        .map(|rd| {
            rd.flatten()
                .map(|e| e.path())
                .filter(|p| p.is_dir())
                .collect()
        })
        .unwrap_or_default();
    dirs.sort();
    dirs
}

/// Every `.nu` file under a category except its own `mod.nu`, relative to it.
fn category_files(dir: &Path, base: &Path, out: &mut Vec<String>) {
    let Ok(entries) = fs::read_dir(dir) else { return };
    let mut paths: Vec<PathBuf> = entries.flatten().map(|e| e.path()).collect();
    paths.sort();
    for path in paths {
        if path.is_dir() {
            category_files(&path, base, out);
        } else if path.extension().is_some_and(|e| e == "nu") {
            if let Ok(rel) = path.strip_prefix(base) {
                let rel = rel.to_string_lossy().to_string();
                if rel != "mod.nu" {
                    out.push(rel);
                }
            }
        }
    }
}

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let want_inventory = args.iter().any(|a| a == "--inventory");
    let quiet = args.iter().any(|a| a == "--quiet");

    let lib = Path::new("lib");
    if !lib.is_dir() {
        eprintln!("run this from the nu_libs repo root — no ./lib directory here");
        std::process::exit(2);
    }

    let have_nu = run_nu("print ok").is_some();
    if !have_nu {
        eprintln!("nushell not found on PATH — skipping the load checks.");
        eprintln!("the inventory below is static and still accurate.\n");
    }

    let cats = categories(lib);
    let mut checks: Vec<FileCheck> = Vec::new();
    let mut mod_results: Vec<(String, Outcome)> = Vec::new();

    for cat in &cats {
        let name = cat.file_name().unwrap().to_string_lossy().to_string();
        let required = globbed(&cat.join("mod.nu"));
        let mut files = Vec::new();
        category_files(cat, cat, &mut files);

        for rel in files {
            let outcome = if have_nu {
                check_module(&cat.join(&rel))
            } else {
                Outcome { ok: true, message: String::new() }
            };
            checks.push(FileCheck {
                category: name.clone(),
                required: required.contains(&rel),
                file: rel,
                parses: outcome.ok,
                message: outcome.message,
            });
        }

        let mod_nu = cat.join("mod.nu");
        if have_nu && mod_nu.exists() {
            mod_results.push((name.clone(), check_use(&mod_nu)));
        }
    }

    if !quiet && have_nu {
        println!("Parse check — nu-check --as-module over {} files\n", checks.len());
        println!("  {:<12} {:>5} {:>9} {:>9} {:>9}", "category", "files", "required", "req ok", "excl fail");
        for cat in &cats {
            let name = cat.file_name().unwrap().to_string_lossy().to_string();
            let rows: Vec<&FileCheck> = checks.iter().filter(|c| c.category == name).collect();
            if rows.is_empty() {
                continue;
            }
            let req = rows.iter().filter(|c| c.required).count();
            let req_ok = rows.iter().filter(|c| c.required && c.parses).count();
            let ex_bad = rows.iter().filter(|c| !c.required && !c.parses).count();
            println!("  {:<12} {:>5} {:>9} {:>9} {:>9}", name, rows.len(), req, req_ok, ex_bad);
        }

        let broken: Vec<&FileCheck> = checks.iter().filter(|c| !c.required && !c.parses).collect();
        if !broken.is_empty() {
            println!("\nExcluded files that do not parse as modules — expected, not failures:");
            for c in &broken {
                println!("  {}/{}  {}", c.category, c.file, c.message);
            }
        }

        println!("\nCategory load — use lib/<category>/mod.nu *");
        for (name, outcome) in &mod_results {
            println!(
                "  {:<12} {}{}",
                name,
                if outcome.ok { "ok" } else { "FAIL" },
                if outcome.ok { String::new() } else { format!("  {}", outcome.message) }
            );
        }

        // lib/mod.nu loads every category at once. CLAUDE.md already warns this
        // "may conflict", so it is reported and never fails the run.
        let all = check_use(&lib.join("mod.nu"));
        println!(
            "\nlib/mod.nu: {}",
            if all.ok { "loads".to_string() } else { format!("reported only — {}", all.message) }
        );
    }

    if want_inventory {
        inventory(&cats);
    }

    let file_failures: Vec<&FileCheck> = checks.iter().filter(|c| c.required && !c.parses).collect();
    let mod_failures: Vec<&(String, Outcome)> = mod_results.iter().filter(|(_, o)| !o.ok).collect();

    if !have_nu {
        std::process::exit(1);
    }

    if file_failures.is_empty() && mod_failures.is_empty() {
        println!("\nall required modules parse and every category loads");
        return;
    }

    println!("\n{} failure(s)", file_failures.len() + mod_failures.len());
    for c in &file_failures {
        println!("  {}/{}  {}", c.category, c.file, c.message);
    }
    for (name, o) in &mod_failures {
        println!("  {}/mod.nu  {}", name, o.message);
    }
    std::process::exit(1);
}

/// What each category actually gives you, plus the two shapes that surprise
/// people: globbed files exporting nothing, and several globbed files exporting
/// `main`.
fn inventory(cats: &[PathBuf]) {
    println!("\nInventory\n");
    println!("  {:<12} {:>14} {:>10}", "category", "globbed files", "commands");

    let mut empties: Vec<(String, String)> = Vec::new();
    let mut mains: BTreeMap<String, Vec<String>> = BTreeMap::new();

    for cat in cats {
        let name = cat.file_name().unwrap().to_string_lossy().to_string();
        let required = globbed(&cat.join("mod.nu"));
        let mut count = 0usize;
        for rel in &required {
            let file = cat.join(rel);
            if !file.exists() {
                println!("  !! {name}/{rel} is glob-re-exported but missing from disk");
                continue;
            }
            let cmds = exports(&file);
            count += cmds.len();
            if cmds.is_empty() {
                empties.push((name.clone(), rel.clone()));
            }
            if cmds.iter().any(|c| c == "main") {
                mains.entry(name.clone()).or_default().push(rel.clone());
            }
        }
        println!("  {:<12} {:>14} {:>10}", name, required.len(), count);
    }

    if !empties.is_empty() {
        println!("\nGlobbed but export nothing — contribute no commands to `use lib/<category> *`:");
        for (cat, file) in &empties {
            println!("  {cat}/{file}");
        }
    }

    let collisions: Vec<(&String, &Vec<String>)> = mains.iter().filter(|(_, v)| v.len() > 1).collect();
    if !collisions.is_empty() {
        println!("\nCategories globbing more than one file that exports `main`:");
        for (cat, files) in collisions {
            println!("  {cat}: {}", files.join(", "));
        }
    }
}
