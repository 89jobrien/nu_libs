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

```
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
  misc/           asciinema, zellij, rustic, bw/rbw, website builder
  hooks/          git hook helpers
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

These conflict when re-exported from a category mod:

| File                            | Command                       |
| ------------------------------- | ----------------------------- |
| `lib/git/bump-version.nu`       | `bump-version`                |
| `lib/fs/loc.nu`                 | `loc` (tokei wrapper)         |
| `lib/fs/wc.nu`                  | `wc`                          |
| `lib/fs/pwd-short.nu`           | `pwd-short`                   |
| `lib/fs/up.nu`                  | `up`                          |
| `lib/data/expand.nu`            | `expand`                      |
| `lib/data/typeof.nu`            | `typeof`                      |
| `lib/data/base64_encode.nu`     | `base64_encode`               |
| `lib/data/remove-diacritics.nu` | `remove-diacritics`           |
| `lib/std/nu_deps.nu`            | `nu-deps`                     |
| `lib/std/nu_release.nu`         | `nu-release`                  |
| `lib/std/cmd_stats.nu`          | `cmd_stats`                   |
| `lib/task/after.nu`             | `after` (wait for process)    |
| `lib/task/just.nu`              | `just` (completions wrapper)  |
| `lib/task/task.nu`              | `task` (lists task commands)  |
| `lib/ui/pick.nu`                | `pick` (fuzzy-select wrapper) |
| `lib/task/bm.nu`                | `bm` (bookmark help)          |

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
