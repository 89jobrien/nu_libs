# nu_libs

A library of Nushell modules organized by category.

## Structure

```
lib/
  mod.nu      top-level re-export of all categories
  git/        Git helpers: log stats, branch age/cleanup, gone branches, hooks
  net/        Network: SSH, sockets, remoting, HTTP, netcat, proxy, SSL
  fs/         Filesystem: tree traversal, file ops, disk, navigation (up/cdpath/autojump/zoxide)
  data/       Data transforms: typeof, JSON schema, ini, env, number format, base64, indent
  ui/         UI/shell: bar, progress meter, completions, aliases (bat/eza), clipboard, notify
  std/        Nu ecosystem: config, init, modules, deps, release tooling, dynamic loading
  task/       Productivity: task runner, todo, history, bookmarks, just completions, hosts/path
  rust/       Rust/Cargo: cargo search, rust AST, coverage
  doob/       Doob wrappers: repo-scoped todos, search, notes, handoff sync
  misc/       Misc tools: asciinema, zellij, rustic, bw/rbw, website builder

scripts/      Standalone scripts (not modules — contain top-level executable code)
ai_nu/        Separate repo: AI/LLM agent primitives (OpenAI, Gemini, Ollama)
```

## Usage

```nu
# Load a whole category
use lib/git *

# Load a single file
use lib/data/typeof.nu *

# Load everything
use lib/mod.nu *
```

### Files with `export def main`

These conflict when glob-re-exported, so use them directly by file path:

| File                            | Command                      |
| ------------------------------- | ---------------------------- |
| `lib/git/bump-version.nu`       | `bump-version`               |
| `lib/fs/loc.nu`                 | `loc` (tokei wrapper)        |
| `lib/fs/wc.nu`                  | `wc`                         |
| `lib/data/expand.nu`            | `expand`                     |
| `lib/data/remove-diacritics.nu` | `remove-diacritics`          |
| `lib/std/nu_deps.nu`            | `nu-deps`                    |
| `lib/std/nu_release.nu`         | `nu-release`                 |
| `lib/task/after.nu`             | `after` (wait for process)   |
| `lib/task/just.nu`              | `just` (completions wrapper) |

```nu
use lib/fs/loc.nu
loc src/
```
