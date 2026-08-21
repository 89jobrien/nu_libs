# lib/ui

Shell UI: progress meters, clipboard, notifications, completion generation, and
aliases for `bat` and `eza`.

```nu
use lib/ui *
```

## Commands

| Command                | From                     | Does                                          |
| ---------------------- | ------------------------ | --------------------------------------------- |
| `loading`              | `percent_meter.nu`       | Animated 0–100 progress meter                 |
| `show_cursor` / `hide_cursor` | `percent_meter.nu`| Terminal cursor visibility                    |
| `demo_percent_meter`   | `percent_meter.nu`       | Demo of the meter                             |
| `watch-clip <closure>` | `clip.nu`                | Watch the clipboard, run a closure per change |
| `notify-self [msg]`    | `notify.nu`              | Desktop notification via `notify-send`        |
| `from tree`            | `completion-generator.nu`| Turn a command tree into completions          |
| `flare`, `math`        | `completion-generator.nu`| Generated completion wrappers                 |

### Aliases

| `bat`                          | | `eza`                                |
| ------------------------------ |-| ------------------------------------ |
| `b` → `bat`                    | | `xs` → `eza --icons`                 |
| `bn` → `bat --number`          | | `xa` → `eza --icons --all`           |
| `bp` → `bat --plain`           | | `xl` → `eza --long`                  |
| `bl` → `bat --line-range`      | | `xla` → `eza --long --all`           |
| `bnl` → `bat --number --line-range` | | `xt` → `eza --icons --tree`     |
| `bpl` → `bat --plain --line-range`  | | `xta` → `eza --icons --tree --all` |

## Not re-exported by `mod.nu`

| File      | Why                                        | Use                     |
| --------- | ------------------------------------------ | ----------------------- |
| `bar.nu`  | Command name `bar` clashes with the module name | `use lib/ui/bar.nu *` |
| `pick.nu` | `export def main` — bare `main` would collide   | `use lib/ui/pick.nu`  |

```nu
use lib/ui/bar.nu *
bar 0.71        # ███▌   — width defaults to 5

use lib/ui/pick.nu
ls | get name | pick
```

`bar` renders a proportional bar from a 0–1 percentage. `pick` is a fuzzy
selector over piped input, wrapping the external `pick` tool, which reads plain
newline-delimited choices.

## Requires

`bat` and `eza` for the aliases, `notify-send` for `notify-self`, `wl-paste`
(Wayland) for `watch-clip`, and `pick` for `pick.nu`. `watch-clip` is
Wayland-only as written.
