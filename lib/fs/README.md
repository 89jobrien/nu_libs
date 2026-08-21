# lib/fs

Filesystem: tree traversal, file ops, disk info, and directory navigation.

```nu
use lib/fs *
```

## Commands

| Command                  | From                    | Does                                                    |
| ------------------------ | ----------------------- | ------------------------------------------------------- |
| `visit`                  | `tree.nu`               | Apply a closure to every node of an input tree, recursively |
| `find in`                | `find_in.nu`            | Search terms across files/folders matching a glob        |
| `extract`                | `ultimate_extractor.nu` | Extract an archive, dispatching on extension             |
| `dfx`                    | `disk.nu`               | Disk usage joined with `sys disks` type/removable/kind   |
| `up [n]`                 | `up.nu`                 | Go up *n* directories                                    |
| `pwd-short`              | `pwd-short.nu`          | `pwd` with `$HOME` abbreviated to `~`                    |
| `j <dir>`                | `autojump.nu`           | `cd` via `autojump`                                      |

### Two globbed files that give you nothing

`mod.nu` glob-imports `cdpath.nu` and `zoxide-menu.nu`, but neither exports a
command at the top level:

- **`cdpath.nu`** wraps everything in an inner `module cdpath` and does a
  file-local `use cdpath c`. Its `c` command — `cd` that searches `$env.CDPATH`
  — never escapes the file. To get it, load the file and reach into the inner
  module. It also requires you to set `$env.CDPATH` yourself:

  ```nu
  $env.CDPATH = [".", "~", "~/path/to/repositories"]
  ```

  Known gap, per its own header comment: `c` does not complete paths starting
  with `~`.

- **`zoxide-menu.nu`** has only an `export-env` block — it installs a menu,
  contributing no command.

## Not re-exported by `mod.nu`

`use lib/fs *` gives you the table above and nothing else. These need a direct path:

| File                          | Why it's excluded                                            | Use                              |
| ----------------------------- | ------------------------------------------------------------ | -------------------------------- |
| `loc.nu`                      | `export def main` — bare `main` would collide                | `use lib/fs/loc.nu`              |
| `wc.nu`                       | same                                                         | `use lib/fs/wc.nu`               |
| `file.nu`                     | Uses a relative cross-domain `use nushell.nu`                | `use lib/fs/file.nu *` (after putting `nushell.nu` on the path) |
| `directory.nu`                | Top-level record literal (keybinding config), not a module   | source it from your config       |
| `filesize.nu`                 | Script — bare pipeline, not a module                         | `use lib/fs/filesize.nu`         |
| `file_convert_naming_case.nu` | Script — bare pipeline, not a module                         | `use lib/fs/file_convert_naming_case.nu` |

```nu
use lib/fs/loc.nu
loc src/
```

`file.nu` is the biggest thing behind that wall — it holds `is-binary-file`,
`verify-integrity`, `with-cd`, `not-subpath`, `nd` (mkdir then cd),
`into-tree`, and `rename-by-modified`.

## Env-mutating modules

`autojump.nu` and `zoxide-menu.nu` carry `export-env` blocks that run at `use`
time and mutate the caller's environment — `autojump.nu` registers a `PWD`
change hook, `zoxide-menu.nu` installs a navigation menu. Loading the category
therefore has side effects on `$env.config`. That is intended, but it means
`use lib/fs *` is not free of consequences the way a pure module would be.

## Two `main`s in one module

`up.nu` and `pwd-short.nu` both carry `export def main`, and `mod.nu` glob-imports both. Whether
that resolves cleanly, last-wins, or errors has not been verified against a
live Nushell. If `up` / `pwd-short` misbehave after `use lib/fs *`, load the file
directly instead — that path is unambiguous.

## Requires

`autojump`, `zoxide` for their respective wrappers; `tokei` for `loc`.
Everything else is built on Nushell builtins.
