# nu_libs

A library of Nushell modules organized by category.

## Structure

```text
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
  misc/       Misc tools: asciinema, zellij, rustic, rbw, website builder

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

## CLI completions

`completions/*.nu` contains native Nushell extern definitions emitted by local CLIs.
`completions/carapace/*.yaml` covers active local CLIs that do not emit Nushell completions.

Carapace is already used as Nushell's external completer. Install or refresh the tracked specs:

```nu
sync-carapace-specs
```

The command honors an absolute `XDG_CONFIG_HOME`, uses
`~/Library/Application Support/carapace/specs` on macOS, `%APPDATA%/carapace/specs` on
Windows, and `~/.config/carapace/specs` elsewhere. It updates tracked specs without removing
unrelated user specs. Use `sync-carapace-specs --dry-run` to preview destinations.

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
| `lib/rust/taskit-release.nu`    | `taskit-release`             |

```nu
use lib/fs/loc.nu
loc src/
```
