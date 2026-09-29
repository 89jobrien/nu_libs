#!/usr/bin/env nu
# Generate a project index for a multi-repo workspace, derived from the repos
# on disk rather than hand-maintained.
#
# WHY SELECTION IS A NAME LIST AND NOT A HEURISTIC
#
# Measured across 99 repos in ~/dev, every automatic "is this substantial?"
# signal was tried and failed:
#   - README.md        present in 99/99      -> carries no information
#   - last commit      64/99 within 7 days  -> carries no information
#   - file markers     taskit.toml 15, Justfile 27, Cargo 75
# A composite score (taskit +2, AGENTS.md +2, description +1, Justfile/Makefile
# +1, multi-crate +1) was measured against the 22 hand-curated projects:
# their scores ranged 0..6, and 35 non-curated repos scored >= 3. A threshold
# of 3 excluded 11 real projects (devloop, rx, obfsck, sparkfile, personal-mcp,
# numcp, maid, romp, hj at 3; godmode 2; nu_libs 0); a threshold of 2 admitted
# 37 scratch repos. No cut separates the sets.
#
# So the human decides WHICH repos matter -- but only by listing names, one per
# line. Everything factual in the table (toolkit, description, crate count, last
# commit) is derived automatically. `proj-index --auto` proposes a starting
# list from the heuristic if you have none.
#
# Requires: git, and (for descriptions) Cargo.toml / README.md / AGENTS.md.
#
# Usage:
#   use ~/dev/nu_libs/lib/workspace/proj-index.nu *
#
#   proj-index                 # write ~/dev/PROJECTS.md from the include list
#   proj-index --check         # exit 1 if PROJECTS.md is stale (for hooks/CI)
#   proj-index --stdout        # print the table, write nothing
#   proj-index --auto          # suggest an include list, write nothing
#   proj-index --root ~/dev/other --include other.list --out ~/dev/OTHER.md

# ---------- detection helpers ----------

def has [p: string, f: string] { ($"($p)/($f)" | path exists) }

# Read a text file. `open --raw` returns a BYTE stream, so an explicit
# `into string` is required or every downstream string filter silently no-ops.
def read-text [p: string, f: string] {
  try { open --raw $"($p)/($f)" | into string } catch { "" }
}

# Cargo description, checking [package] then [workspace.package].
def cargo-desc [p: string] {
  if not (has $p "Cargo.toml") { return null }
  try {
    let t = (open ($p | path join "Cargo.toml"))
    let d = (try { $t | get package.description } catch { null })
    if $d == null {
      (try { $t | get workspace.package.description } catch { null })
    } else {
      $d
    }
  } catch { null }
}

def crate-count [p: string] {
  if not (has $p "Cargo.toml") { return 0 }
  try {
    let t = (open ($p | path join "Cargo.toml"))
    let m = (try { $t | get workspace.members } catch { null })
    if $m == null { 1 } else { $m | length }
  } catch { 0 }
}

# True when a line is real prose rather than markup. Kept as a named def
# because a multi-line `and` chain inside a `where` closure does not parse.
def is-prose [l: string] {
  let t = ($l | str trim)
  if $t == "" { return false }
  for p in ["#" "![" "<" "[!" "```" "---" "===" "|" "*" "- " "> " "+" "1." "• "] {
    if ($t | str starts-with $p) { return false }
  }
  if ($t =~ '^\s*https?://') { return false }
  true
}

# First meaningful prose line from README.md, else AGENTS.md / CLAUDE.md.
def prose [p: string] {
  let f = (
    if (has $p "README.md") { "README.md" }
    else if (has $p "AGENTS.md") { "AGENTS.md" }
    else if (has $p "CLAUDE.md") { "CLAUDE.md" }
    else { return null }
  )
  let found = (
    (read-text $p $f)
    | lines
    # `where is-prose` fails: the hyphen is parsed as a cell path, so the named
    # def must be invoked from inside a closure.
    | where {|l| is-prose $l }
    | first
    | default null
  )
  if $found == null { null } else { $found | str trim }
}

def last-commit [p: string] {
  (^git -C $p log -1 --format=%cs | complete | get stdout | str trim | default "")
}

# Toolkit, derived from marker files. `taskit.toml` is the strong signal;
# a bare xtask crate without it means a hand-rolled `cargo xtask`.
# A `lib/mod.nu` is a real signal that a repo is primarily a nu module library
# (nu_libs also has a small Cargo crate, so both are reported).
def toolkit [p: string] {
  let just = ((has $p "Justfile") or (has $p "justfile"))
  let cargo = (has $p "Cargo.toml")
  let is_nu = (has $p "lib/mod.nu")

  if (has $p "taskit.toml") {
    if $just { "`just` / `cargo xtask` (taskit)" } else { "`cargo xtask` (taskit)" }
  } else if $cargo and $is_nu {
    "`nu` / `cargo`"
  } else if $is_nu {
    "`nu`"
  } else if $cargo {
    let custom_xtask = ((has $p "xtask") or (has $p "crates/xtask") or (has $p "xtask/Cargo.toml"))
    if $custom_xtask {
      "`cargo xtask` (custom)"
    } else if $just {
      "`just` / `cargo`"
    } else {
      "`cargo`"
    }
  } else if $just {
    "`just`"
  } else if (has $p "Makefile") {
    "`make`"
  } else if (has $p "package.json") {
    "npm"
  } else if (has $p "pyproject.toml") {
    "python"
  } else if (has $p "go.mod") {
    "go"
  } else {
    # Directory exists but carries no build marker: an empty placeholder or a
    # private/permission-restricted checkout. Do NOT call this "docs only",
    # which would assert something we have not verified.
    "_no build markers found_"
  }
}

# A `|` inside a cell would split the markdown table.
def cell [s: string] { $s | str replace -r '\|' '\\|' | str replace -r '\s+' ' ' | str trim }

def one-line [s: string, n: int] {
  let t = ($s | str trim)
  if (($t | str length) <= $n) { $t } else { $"($t | str substring 0..($n - 1))…" }
}

# ---------- main ----------

# [nu_lib] Generate a workspace project index from repos on disk.
export def main [
  --root: string = ""          # workspace root (default: $HOME)
  --include: string = ""       # name list file (default <root>/.proj-index-include)
  --out: string = ""           # output file (default <root>/PROJECTS.md)
  --check                      # exit 1 if --out is stale; write nothing
  --stdout                     # print the table; write nothing
  --auto                       # suggest an include list from heuristics
  --min-score: int = 3         # --auto only: composite score threshold
] {
  # Flag defaults must be constant expressions, so these are resolved here
  # rather than in the signature. NUXT_WORKSPACE_ROOT overrides the default.
  let root_home = (
    if $root != "" {
      $root | path expand
    } else {
      let envroot = ($env | get -o NUXT_WORKSPACE_ROOT)
      let base = (if ($envroot | is-not-empty) { $envroot } else { ($env.HOME | path join "dev") })
      $base | path expand
    }
  )

  if $auto {
    let entries = (ls $root_home | get name | where {|p| ($"($p)/.git" | path exists) } | sort)
    let scored = ($entries | each {|p|
      let name = ($p | path basename)
      let tk = (has $p "taskit.toml")
      let ag = (has $p "AGENTS.md")
      let de = (cargo-desc $p) != null
      let jm = ((has $p "Justfile") or (has $p "justfile") or (has $p "Makefile"))
      let cc = (crate-count $p)
      let sc = (if $tk { 2 } else { 0 }) + (if $ag { 2 } else { 0 }) + (if $de { 1 } else { 0 }) + (if $jm { 1 } else { 0 }) + (if $cc > 1 { 1 } else { 0 })
      let rec = { name: $name score: $sc }
      $rec
    })
    print $"# suggested include list, score at least ($min_score) -- EDIT THIS, heuristics cannot tell real from scratch"
    print ($scored | where {|r| $r.score >= $min_score} | sort-by --reverse score | get name | each {|n| $n } | str join (char nl))
    return
  }

  let inc_path = (if $include == "" { $"($root_home)/.proj-index-include" } else { $include })
  if not ($inc_path | path exists) {
    error make { msg: $"no include list at ($inc_path). Create it with one repo name per line, or run `proj-index --auto` to get a starting list." }
  }

  let names = (
    $inc_path
    | open --raw
    | into string
    | lines
    | each {|l| $l | str trim }
    | where {|l| ($l != "") and not ($l | str starts-with "#") }
  )

  if ($names | is-empty) {
    error make { msg: $"include list ($inc_path) is empty" }
  }

  let rows = ($names | each {|n|
    let p = ($root_home | path join $n)
    # "exists" and "is a git repo" are different facts. `maestro` exists on
    # disk but carries no .git and no build markers; `dotfiles` is gone. Only
    # the latter should be reported as MISSING.
    let exists = ($p | path exists)
    let is_repo = ($"($p)/.git" | path exists)
    let desc = (cargo-desc $p)
    let pro = (if $desc != null { $desc } else { prose $p })
    let rec = {
      name: $n
      exists: $exists
      repo: $is_repo
      desc: (if $pro == null { "" } else { $pro })
      toolkit: (if $exists { toolkit $p } else { "_MISSING_" })
      crates: (if $is_repo { crate-count $p } else { 0 })
      last: (if $is_repo { last-commit $p } else { "" })
    }
    $rec
  })

  let missing = ($rows | where {|r| $r.exists == false} | get name)
  # Present on disk but not a git checkout: usually an empty placeholder or a
  # private/permission-restricted repo. Worth its own note, since a missing
  # build marker there is not evidence the project is empty.
  let not_repo = ($rows | where {|r| $r.exists and ($r.repo == false)} | get name)

  let header = [
    "# Project Index"
    ""
    $"<!-- GENERATED by proj-index from ($inc_path). Do not edit by hand;"
    " run `proj-index` to refresh, `proj-index --check` to verify. -->"
    ""
    $"($rows | length) projects, selected by name in `($inc_path | path basename)`."
    "Columns are derived from each repo's files and git history."
    ""
    "| Project | What it is | Toolkit | Crates | Last commit |"
    "| --- | --- | --- | ---: | --- |"
  ]

  let body = (
    $rows
    | each {|r|
        let d = (if $r.desc == "" { "_(no description found)_" } else { one-line $r.desc 70 })
        $"| ($r.name) | (cell $d) | ($r.toolkit) | (($r.crates)) | ($r.last) |"
    }
    | str join (char nl)
  )

  # Built with a mutable accumulator rather than a list literal containing
  # `if` expressions: the nested form silently injected a stray element, which
  # showed up as a trailing `*` line in the output.
  mut fparts = []
  if ($missing | is-not-empty) {
    let items = ($missing | each {|m| $"- `($m)`" } | str join (char nl))
    $fparts = ($fparts | append ["", "## Listed but not on disk", "", $items])
  }
  if ($not_repo | is-not-empty) {
    let items = ($not_repo | each {|m| $"- `($m)`" } | str join (char nl))
    $fparts = ($fparts | append ["", "## On disk but not a git checkout", "", $items, "", "Empty placeholders or permission-restricted checkouts: no .git and no build markers, so toolkit and last-commit are unknown."])
  }
  # `append` with a LIST argument nests it as a single element rather than
  # splicing, and `str join` then stringifies that structure into the document
  # (which showed up as stray `*` lines). So the footer is flattened to ONE
  # string before being appended.
  let footer_text = (if ($fparts | is-empty) { "" } else { $fparts | str join (char nl) })
  let chunks = ($header | append $body | append $footer_text)

  # Two traps here, both silent:
  #   `append` on a STRING returns a LIST ["a" "\n"], it does not concatenate
  #     -- so `save` stringified a 2-element list into a stray `*` line.
  #   `| $"\n"` is not an append either: piping into a string literal discards
  #     the pipeline input, yielding a document of just a newline.
  let doc = (($chunks | str join (char nl)) + (char nl))

  if $stdout {
    # Returned rather than printed, so callers can capture it with
    # `let doc = (proj-index --stdout)`. `nu -c` surfaces the final value.
    return $doc
  }

  let out_path = (if $out == "" { $"($root_home)/PROJECTS.md" } else { $out })

  if $check {
    if not ($out_path | path exists) {
      error make { msg: $"($out_path) does not exist. Run `proj-index` to create it." }
    }
    let cur = (open --raw $out_path | into string)
    if $cur == $doc {
      print $"proj-index: ($out_path) is up to date"
    } else {
      print $"proj-index: STALE — ($out_path) differs from what the repos imply. Run `proj-index`."
      exit 1
    }
    return
  }

  $doc | save --force $out_path
  print $"proj-index: wrote ($out_path) (($rows | length)) projects"
  if ($missing | is-not-empty) {
    print $"  warning: listed but missing on disk: ($missing | str join ' ')"
  }
}
