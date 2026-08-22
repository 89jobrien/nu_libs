# nu_libs

A library of Nushell modules organized by category.

## Structure

Each category has its own `README.md` with a command table, the files `mod.nu`
does *not* re-export and why, and external tool requirements.

| Category                            | Contents                                                             |
| ----------------------------------- | -------------------------------------------------------------------- |
| [`lib/git`](lib/git/README.md)      | Log views, branch age/cleanup, gone branches, hooks, version bumping |
| [`lib/net`](lib/net/README.md)      | SSH config + remoting, sockets, HTTP, netcat, proxy, SSL             |
| [`lib/fs`](lib/fs/README.md)        | Tree traversal, file ops, disk, navigation (up/cdpath/autojump/zoxide) |
| [`lib/data`](lib/data/README.md)    | typeof, JSON schema, ini, env, number format, base64, indent         |
| [`lib/ui`](lib/ui/README.md)        | Bars, progress meters, completions, bat/eza aliases, clipboard, notify |
| [`lib/std`](lib/std/README.md)      | Nu ecosystem: config, init, modules, deps, release tooling           |
| [`lib/task`](lib/task/README.md)    | pueue task runner, bookmarks, todo, history, hosts/path              |
| [`lib/rust`](lib/rust/README.md)    | Cargo wrappers, Rust AST toolkit, coverage, SARIF enrichment         |
| [`lib/ai`](lib/ai/README.md)        | LLM agent primitives (vendored from `ai_nu`)                         |
| [`lib/doob`](lib/doob/README.md)    | doob wrappers: repo-scoped todos, search, notes, handoff sync        |
| [`lib/gkg`](lib/gkg/README.md)      | Knowledge graph queries and the `.kgx` wiki                          |
| [`lib/hooks`](lib/hooks/README.md)  | Claude Code hook I/O primitives                                      |
| [`lib/misc`](lib/misc/README.md)    | asciinema, zellij, rbw, project registry, unit conversion            |
| [`lib/extensions`](lib/extensions/README.md) | Project-specific integrations (magi)                        |

```
lib/mod.nu    top-level re-export of all categories
scripts/      Standalone scripts (not modules — contain top-level executable code)
```

## Testing

```bash
./scripts/test-load.rs               # load test
./scripts/test-load.rs --inventory   # + per-category inventory
```

A [rust-script](https://rust-script.org/) — dependency-free, so it needs only a
Rust toolchain and `rust-script` on `PATH`. Nushell must also be installed; the
harness shells out to it and tells you plainly if it is missing.

Two checks, both free of side effects. `nu-check --as-module` parses every
`.nu` file without executing it — which matters, since several files are bare
pipelines that would run git commands if `use`d. Then each category is loaded
with `use lib/<category>/mod.nu *` in a subprocess, so the `export-env` blocks
scattered through the tree cannot leak into your shell.

The contract comes from the `mod.nu` files themselves: a file a category
glob-re-exports must parse as a module. Files `mod.nu` deliberately leaves out
are reported, never failed — being unloadable is often exactly why they were
excluded. `--inventory` adds command counts per category and flags the two
shapes that surprise people: globbed files that export nothing, and categories
globbing more than one file that exports `main`.

Runs on every push via `.github/workflows/load-test.yml`, which compiles the
script directly with `rustc` rather than installing `rust-script`.

## Usage

```nu
# Load a whole category
use lib/git *

# Load a single file
use lib/data/typeof.nu *

# Load everything
use lib/mod.nu *
```

### Files a category `mod.nu` does not re-export

`use lib/<category> *` gives you less than the directory contains. Files are
left out for four reasons — `export def main` (bare `main` would collide), a
command name clashing with the module name, the file being a script or a
keybinding-config record rather than a module, or a missing/broken dependency.

Each category README lists its own exclusions with the reason for each. The
files excluded specifically because of `export def main`:

| File                            | Command                       |
| ------------------------------- | ----------------------------- |
| `lib/git/bump-version.nu`       | `bump-version`                |
| `lib/fs/loc.nu`                 | `loc` (tokei wrapper)         |
| `lib/fs/wc.nu`                  | `wc`                          |
| `lib/data/expand.nu`            | `expand`                      |
| `lib/data/remove-diacritics.nu` | `remove-diacritics`           |
| `lib/std/nu_deps.nu`            | `nu-deps`                     |
| `lib/std/nu_release.nu`         | `nu-release`                  |
| `lib/task/after.nu`             | `after` (wait for process)    |
| `lib/task/just.nu`              | `just` (completions wrapper)  |
| `lib/ui/pick.nu`                | `pick` (fuzzy-select wrapper) |
| `lib/ai/list-hooks.nu`          | `list-hooks`                  |

### Known rough edge: `main` collisions inside a category

Nine other files export `main` and *are* glob-re-exported by their `mod.nu`
anyway. In four categories that means two `main`-exporting files are globbed
into the same module:

| Category | Globbed files exporting `main`                        |
| -------- | ----------------------------------------------------- |
| `data`   | `typeof.nu`, `base64_encode.nu`                       |
| `fs`     | `up.nu`, `pwd-short.nu`                               |
| `net`    | `sockets.nu`, `ssh.nu` (the latter an `export extern`)|
| `task`   | `task.nu`, `bm.nu`                                    |

(`std/cmd_stats.nu` is the ninth, and is alone in its category.)

Whether that resolves cleanly, last-wins, or errors has not been verified
against a live Nushell. If `use lib/fs *` behaves oddly around `up`/`pwd-short`,
or `use lib/task *` around `task`/`bm`, this is the first thing to check —
loading the file directly always works:

```nu
use lib/fs/loc.nu
loc src/
```
