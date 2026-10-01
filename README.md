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
  sys/        macOS system inspection: process memory, swap pressure, disk bloat
  workspace/  Multi-repo workspace introspection (proj-index)

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

These are **omitted from their category `mod.nu`**, so globbing the category does
not bring them into scope. Load them by file path:

```nu
use lib/fs/loc.nu *
loc src/
```

Glob re-export does **not** strip `export def main` — the note here previously
claimed it did, which is wrong. `lib/sys/mod.nu` exports all five of its `main`
files and all five resolve through `use lib/sys *`.

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

## lib/workspace — proj-index

Generates `~/dev/PROJECTS.md` from the repos on disk: name, description,
toolkit, crate count, last commit.

```nu
proj-index            # rewrite PROJECTS.md
proj-index --check    # exit 1 if stale
proj-index --auto     # suggest names for the include list
```

Selection is a curated **name list** at `~/dev/.proj-index-include`, because
every automatic "is this repo substantial?" signal was measured and failed:
README.md exists in 99/99 repos, 64/99 committed within the week, and a
composite marker score put real projects at 0..6 while 35 scratch repos scored
3+. Everything except selection is derived automatically.

## lib/sys — system inspection

macOS process memory, swap pressure, and on-disk bloat. Read-only except
`sys-reap`, which kills and refuses its own ancestry; `sys-disk` never deletes.

```nu
sys-scan | sys-triage      # classify, ranked by reclaimable swap
sys-reap --pids [...]      # SIGTERM; add --escalate for SIGKILL survivors
sys-disk --depth 1         # categorised disk report (slow: ~90-135s on ~/dev)
```

Validate with `nu --no-config-file lib/sys/validate.nu`, and
`lib/sys/validate-load.nu` for the full-`use lib/mod.nu *` path. See the
`sys-usage` skill for the workflow and encoded gotchas.

Note: `lib/task/task.nu` exports `kill` for pueue, which shadows nu's builtin
`kill` and breaks any module that calls `kill` by name at parse time. Use
`/bin/kill` with numeric signals, as `lib/sys/sys-reap.nu` does.
