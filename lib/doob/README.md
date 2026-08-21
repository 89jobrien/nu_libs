# lib/doob

Nushell wrappers around the external `doob` CLI, for repo-scoped todos, notes,
search, and handoff state.

```nu
use lib/doob *
```

## Commands

| Command             | Does                                                    |
| ------------------- | ------------------------------------------------------- |
| `doob pending`      | Pending todos, scoped to the current repo by default     |
| `doob find`         | Search todos and notes, repo-scoped by default            |
| `doob note list`    | List notes                                               |
| `doob note add`     | Add a note                                               |
| `doob handoff list` | List handoff items                                       |
| `doob handoff sync` | Sync `HANDOFF` state through doob                        |
| `doob raw <args>`   | Pass arguments straight through to the CLI               |

Everything here is a wrapper — `doob raw` is the escape hatch for subcommands
that aren't wrapped yet.

## Requires

The `doob` binary on `PATH`. The repo scoping means these commands behave
differently depending on your working directory.
