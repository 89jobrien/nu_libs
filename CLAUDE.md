# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## What This Is

`nu_libs` is a collection of Nushell modules organized by domain. There is no build system —
modules are sourced directly. There are no tests in the traditional sense; validation is done
by loading modules in a live Nu session.

## Validating Nu Syntax

```nu
# Check a single file parses without errors
nu --no-config-file -c 'use lib/git/git.nu'

# Load a whole category and verify exports
nu --no-config-file -c 'use lib/data/mod.nu *; help commands | where name =~ "^to-"'

# Check a script is valid Nu (no top-level code issues)
nu --no-config-file --no-std-lib --commands 'source scripts/file_cat.nu'
```

## Module Structure

```text
lib/
  mod.nu          top-level re-export of all categories
  git/            branch age/cleanup, gone branches, hooks, bump-version, clone-all
  net/            SSH, sockets, remoting, HTTP request, netcat, proxy, SSL
  fs/             tree, file ops, disk, navigation (up/cdpath/autojump/zoxide)
  data/           typeof, JSON schema, ini, env, number format, base64, indent, expand
  ui/             bar, progress meter, completions, aliases (bat/eza), clipboard, notify
  std/            Nu ecosystem: config, init, modules, deps, release tooling, dynamic loading
  task/           task runner, todo, history, bookmarks, just completions, hosts/path
  rust/           cargo search, rust AST, coverage
  doob/           doob wrappers for repo-scoped todos, search, notes, handoff sync
  misc/           asciinema, zellij, rustic, rbw, website builder
  hooks/          git hook helpers
  sys/            macOS system inspection: process memory, swap pressure, disk bloat
  workspace/      multi-repo workspace introspection (proj-index)
  ai/             LLM agent primitives (vendored from ai_nu — see below)

scripts/          Standalone scripts — contain top-level executable code, NOT safe to `use`
```

Each category has a `mod.nu` that re-exports all files in that directory. Load a category:

```nu
use lib/git *            # load whole git category
use lib/data/typeof.nu * # load single file
use lib/mod.nu *         # load everything (slow, may conflict)
```

### Files with `export def main` — load by file path, not glob

These files are **deliberately omitted from their category `mod.nu`**, so
globbing the category does not bring them into scope. Load them by path:

```nu
use lib/fs/loc.nu *        # `loc` is NOT available via `use lib/fs *`
```

The earlier framing here — that glob re-export _strips_ `export def main` — is
**wrong**, and the table above conflated two different things. Glob re-export
preserves `export def main`; these files are simply not listed in their mod.

Verified: `lib/data/mod.nu` exports `typeof.nu` and `typeof` resolves through
`use lib/data *`. Likewise `std/mod.nu` exports `cmd_stats.nu`, and `fs/mod.nu`
exports `up.nu` and `pwd-short.nu` — all three are in the table below yet work
fine via glob. `lib/sys/mod.nu` exports all five of its `main` files and all
five resolve.

| File                            | Command                       |
| ------------------------------- | ----------------------------- |
| `lib/git/bump-version.nu`       | `bump-version`                |
| `lib/fs/loc.nu`                 | `loc` (tokei wrapper)         |
| `lib/fs/wc.nu`                  | `wc`                          |
| `lib/fs/pwd-short.nu`           | `pwd-short` (also globbed)    |
| `lib/fs/up.nu`                  | `up` (also globbed)           |
| `lib/data/expand.nu`            | `expand`                      |
| `lib/data/typeof.nu`            | `typeof` (also globbed)       |
| `lib/data/base64_encode.nu`     | `base64_encode`               |
| `lib/data/remove-diacritics.nu` | `remove-diacritics`           |
| `lib/std/nu_deps.nu`            | `nu-deps`                     |
| `lib/std/nu_release.nu`         | `nu-release`                  |
| `lib/std/cmd_stats.nu`          | `cmd_stats` (also globbed)    |
| `lib/task/after.nu`             | `after` (wait for process)    |
| `lib/task/just.nu`              | `just` (completions wrapper)  |
| `lib/task/task.nu`              | `task` (lists task commands)  |
| `lib/ui/pick.nu`                | `pick` (fuzzy-select wrapper) |
| `lib/task/bm.nu`                | `bm` (bookmark help)          |

## Command shadowing hazard

`lib/task/task.nu` exports `kill` for pueue, shadowing nu's builtin `kill`.
Resolution happens at **parse** time, so a module in this repo that calls
`kill --quiet ...$pids` fails to _load_ under `use lib/mod.nu *` — the error
surfaces as `unknown flag --quiet` and takes the whole load down, not just that
line. Call `/bin/kill` by absolute path with numeric signals instead; see
`lib/sys/sys-reap.nu` and the `sys-usage` skill. `lib/sys/validate-load.nu`
exists to catch this class of regression, which `validate.nu` cannot, because it
loads by file path.

## lib/sys — system inspection

`lib/sys/` reports process memory, swap pressure, and on-disk bloat on macOS.
Read-only except `sys-reap`, which kills and refuses its own ancestry.
Neither disk command deletes anything, and neither has a delete flag.

```nu
sys-scan | sys-triage      # classify, ranked by reclaimable swap
sys-reap --pids [...]      # SIGTERM; --escalate for SIGKILL survivors
sys-disk --depth 1         # dev-tree report: rebuildable | worktree | git | source
sys-audit                  # home report: cache | rebuildable | vm | container |
                          #   archive | media | appdata | source
```

`sys-disk` answers "which project under `~/dev` is the hog". `sys-audit` answers
"should we clean anything from `~`" — pointed at `$HOME`, `sys-disk` labels
`~/Library/Caches`, `~/.cache` and `~/.minibox` all `source`, because its four
categories are tuned for Rust and JS repos. Both share one classifier
(`lib/sys/disk-classify.nu`) so the two cannot drift.

A `~`-wide scan is slower than the 90-135s `~/dev` scan, and macOS TCC denies
reading much of `~/Library` and `~/.Trash`. Unreadable paths appear in the
`skipped` list rather than being omitted, so a long `skipped` list means the
total is a floor rather than a measurement.

Validate with `nu --no-config-file lib/sys/validate.nu` (by file path) and
`lib/sys/validate-load.nu` (via `lib/mod.nu *`). `lib/sys/validate-classify.nu`
covers the classifier and the disk pipeline against a synthetic fixture. See the
`sys-usage` skill.

## lib/ai Architecture

`lib/ai/` is a vendored copy of the `ai_nu` repo (previously a git submodule). Do not treat
it as a submodule — edit files directly.

Key layers:

- **`sqlite.nu` / `data.nu`**: SQLite-backed session and message storage. All LLM history is
  persisted. `data init` creates the DB; `data make-session` returns a session ID stored in
  `$env.AI_SESSION`.
- **`base.nu`**: Core primitives — `ai-req` (build request), `ai-call` (execute + record),
  `ai-send` (full multi-turn loop with tool use). All dispatch goes through `ai-req`/`ai-call`.
- **`call.nu`**: Exports `ai-new-session` and the `export-env` block that initializes
  `$env.AI_CONFIG`, `$env.AI_PROMPTS`, `$env.AI_TOOLS`.
- **`config.nu`**: Session management — switch provider/model/temperature, upsert prompts and
  providers, query history.
- **`clients/openai.nu`**: HTTP client for OpenAI-compatible APIs (SSE streaming, tool-call
  merging). `clients/gemini.nu` is the Gemini adapter.
- **`integration/`**: Ollama, local (stdin/subprocess), web (browser), audio.
- **`agents/`**: Domain-specific agents (research, ragit, kubernetes, shop, project-manager).
  Each agent uses `ai-send` with a named prompt and tools.
- **`data/tools/`**: Tool schemas (git, web, os, programming, clipboard) registered into
  `$env.AI_TOOLS` at init.
- **`function.nu`**: Closure-based tool dispatch — `closure-list` converts Nu closures to
  tool schemas; `closure-run` executes tool calls returned by the LLM.
- **`mcp.nu`**: MCP client stubs (for future daemon integration).

### Planned: BAML agent daemon

See `docs/plans/2026-06-09-baml-agent-daemon.md`. The design replaces the Nu-driven HTTP
loop with a persistent Rust daemon (`nu-ai-daemon`) that owns multi-turn tool loops. Nu
becomes a tool executor via MCP. The Nu-side wrapper will live at `lib/ai/clients/baml.nu`.
This is in design phase — `lib/ai/clients/baml.nu` does not yet exist.

## Nu Conventions

- No bash-isms: no `&&`, no `$()`, no `export VAR=val`
- `const` cannot reference `$env` — use `let` at runtime
- String interpolation requires parens: `$"text ($expr)"`
- `export-env { ... }` blocks run at `use` time and mutate caller's env
- `export def --env` allows a command to mutate caller's env
- Completions are declared inline with `@completion-fn` on parameter types
- Validate syntax: `nu --no-config-file -c 'use <file>'`
