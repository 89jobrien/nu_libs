# lib/misc

Tools that don't fit another category: terminal recording, password manager,
multiplexer, project registry, unit conversion.

```nu
use lib/misc *
```

## Commands

| Command                 | From           | Does                                             |
| ----------------------- | -------------- | ------------------------------------------------ |
| `ascii-rec`             | `asciinema.nu` | Record a terminal session with `asciinema`       |
| `rbws`                  | `rbw.nu`       | Search the Bitwarden vault via `rbw`             |
| `zellij-session`        | `zellij.nu`    | Session picker                                   |
| `zellij-enter`          | `zellij.nu`    | Attach to a session                              |
| `zellij-delete`         | `zellij.nu`    | Delete a session                                 |
| `zellij-cd`             | `zellij.nu`    | Change a session's directory                     |
| `notify-zellij`         | `zellij.nu`    | Notification into zellij                         |
| `project register`      | `reg.nu`       | Add a project to the registry                    |
| `project unregister`    | `reg.nu`       | Remove one                                       |
| `project init-registry` | `reg.nu`       | Create the registry                              |
| `xx`                    | `reg.nu`       | Execute against a registered project             |
| `f-to-c`, `f-to-k`      | `temp.nu`      | Fahrenheit → Celsius / Kelvin                    |
| `c-to-f`, `c-to-k`      | `temp.nu`      | Celsius → Fahrenheit / Kelvin                    |
| `k-to-f`, `k-to-c`      | `temp.nu`      | Kelvin → Fahrenheit / Celsius                    |

`zellij.nu` carries an `export-env` block, so loading this category touches
`$env`.

## Not re-exported by `mod.nu`

| File                 | Why                                                       | Use                             |
| -------------------- | --------------------------------------------------------- | ------------------------------- |
| `rustic.nu`          | Needs a `parser` module that isn't in this repo           | `use lib/misc/rustic.nu` (will fail without it) |
| `website_builder.nu` | Script — bare pipeline, not a module                      | `use lib/misc/website_builder.nu` |

## Requires

`asciinema`, `rbw`, `zellij` — each command is a thin wrapper and fails without
its tool. `rustic.nu` targets the `rustic` backup tool but is currently
unloadable as noted above.
