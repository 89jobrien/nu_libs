# lib/extensions

Integrations with specific projects that must exist on disk. Unlike other
categories, these are not general-purpose — load them individually.

```nu
use lib/extensions/magi.nu *
```

## `magi` — training loop control

Drives a `magi` RL training daemon and its rewards database.

| Command                | Does                                                              |
| ---------------------- | ----------------------------------------------------------------- |
| `magi-start`           | Start the loop daemon in the background                           |
| `magi-stop`            | SIGTERM — waits for the current cycle to finish                   |
| `magi-ps`              | Daemon status: running/stopped, pid, log tail                     |
| `magi-logs`            | Tail the loop log live                                            |
| `magi-loop`            | One full iteration: interact → score → rl_prompt → maybe rl_weights |
| `magi-interact`        | Interact stage — sample tasks, record interactions to the DB      |
| `magi-score`           | Score stage — score unscored interactions                         |
| `magi-rl-prompt`       | Prompt RL — update system prompt and few-shot pool                |
| `magi-rl-weights`      | Weight RL — fine-tune when the threshold is met                   |
| `magi-reconcile`       | Reconcile the modelcard after a prompt or weight RL run           |
| `magi-dashboard`       | One-shot training dashboard                                       |
| `magi-status`          | Recent interaction stats from the rewards DB                      |
| `magi-prompt-history`  | Prompt update history                                             |
| `magi-weight-history`  | Weight training run history                                       |
| `magi-chat`            | Chat with gemma-lg via Ollama (oneshot by default)                |

Run `magi-reconcile` after `magi-rl-prompt` or `magi-rl-weights` — the
modelcard does not update itself.

`magi.nu` has an `export-env` block, so `use`-ing it mutates your environment.

## Requires

The magi project checked out locally, its rewards DB, and Ollama for
`magi-chat`. None of this works standalone.
