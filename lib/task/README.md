# lib/task

Productivity: a `pueue` task-queue wrapper, directory bookmarks, and host/PATH
maintenance.

## Load these by file, not by category

`task.nu` and `bm.nu` define their subcommands as **bare** names — `spawn`,
`kill`, `status`, `log`, `clean`, `wait`, `list`, `add`, `goto` — which only
become `task spawn` / `bm list` when the file is loaded as a module:

```nu
use lib/task/task.nu     # task, task spawn, task kill, ...
use lib/task/bm.nu       # bm, bm list, bm goto, ...
```

`mod.nu` glob-imports both (`export use ./task.nu *`), which strips that
qualification and drops ~25 very generic commands into your namespace —
including `kill`, `status`, `log`, `start`, `edit`, `send`, `wait`, `remove`,
`clean`, `list`, and `add`. `goto` also collides with the `goto` in
`lib/std/nu_defs.nu`, and both files export `main`.

**Prefer the per-file form above.** The tables below use the qualified names
you get from it.

## `task` — pueue wrapper

`task.nu` is a typed Nushell front end to [`pueue`](https://github.com/Nukesor/pueue).
`pueue` must be installed and its daemon running.

| Command                   | Does                                                          |
| ------------------------- | ------------------------------------------------------------- |
| `task spawn <cmd>`        | Run a task in the background, surviving shell exit. A fresh Nu interpreter is used |
| `task status`             | Status of all tasks                                           |
| `task log`                | Task output — last few lines by default                       |
| `task wait`               | Block until the given tasks finish (`join`/`await`)           |
| `task queue` / `stash`    | Queue stashed tasks / stash one that isn't running            |
| `task start` / `pause`    | Resume / pause tasks or whole groups                          |
| `task kill`               | Kill running tasks or groups                                  |
| `task restart`            | Re-enqueue failed or finished tasks                           |
| `task remove`             | Drop tasks from the queue — kill running ones first           |
| `task switch <a> <b>`     | Swap queue positions of two queued/stashed tasks              |
| `task edit`               | Edit a stashed/queued task's command, path, or label          |
| `task send <text>`        | Send stdin to a task — e.g. a `y\n` confirmation             |
| `task clean`              | Remove finished tasks from the status list                    |
| `task group [add\|remove]`| List, create, or delete groups                               |
| `task set-parallel-limit` | Max parallel tasks in a group. Lowering it stops nothing already running |
| `task shutdown`           | Shut down the pueue daemon — and with it this module          |

## `bm` — bookmarks

| Command       | Does                                     |
| ------------- | ---------------------------------------- |
| `bm`          | General info about `bm`                  |
| `bm list`     | List bookmarked paths                    |
| `bm add [name]` | Bookmark the current path              |
| `bm goto`     | Jump to a bookmark (completion-driven)   |
| `bm goto_alternative` | Experimental — uses `input` instead of completions |
| `bm bm-remove` | Remove one or more bookmarks. Note the doubled prefix — the def is literally named `bm-remove`, not `remove` |
| `bm reset`    | Clear all bookmarks                      |

## Two files that give you nothing

`mod.nu` glob-imports `update-path.nu` and `update_hosts.nu`, but both wrap
their logic in an inner `module` block whose `def`s are not exported — so
neither contributes a single command to `use lib/task *`.

- `update-path.nu` — **Windows only.** Refreshes `Path` so a terminal restart
  isn't needed. Meant to be imported in `config.nu` and hung off the
  `pre_prompt` hook.
- `update_hosts.nu` — `/etc/hosts` update handler, in a `hosts` module.

To use either, import the file and reach into its inner module.

## Not re-exported by `mod.nu`

| File                             | Why                                                    | Use                        |
| -------------------------------- | ------------------------------------------------------ | -------------------------- |
| `after.nu`                       | `export def main` — bare `main` would collide          | `use lib/task/after.nu`    |
| `just.nu`                        | same                                                   | `use lib/task/just.nu`     |
| `todo.nu`                        | **Broken** — old closure syntax `{\|$it, n\|}`, needs `{\|it, n\|}` | fix first, then use directly |
| `history.nu`                     | Keybinding config record, not a module                 | source from your config    |
| `current_session_history_menu.nu`| Keybinding config record, not a module                 | source from your config    |

```nu
use lib/task/after.nu
after 12345 {|| print "process finished" }     # also: before {|| ... } <pid>

use lib/task/just.nu
just               # `just` with completions
```

`todo.nu` will fail to parse as written — that is a known defect, not a loading
mistake. Its `todo` command is meant to be sourced from `config.nu`.

## Requires

`pueue` (daemon running) for `task`; `just` for `just.nu`.
