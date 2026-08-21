# lib/std

Nushell ecosystem tooling: config management, session utilities, dependency and
release tooling for the Nu repo itself, and a large grab-bag of helper commands.

```nu
use lib/std *
```

This is the least uniform category — **10 of its 17 files are not modules at
all** (see below), so what `use lib/std *` gives you is much narrower than the
directory suggests.

## Commands

| Command             | From                       | Does                                                       |
| ------------------- | -------------------------- | ---------------------------------------------------------- |
| `nul-carapace`      | `carapace.nu`              | Generate carapace spec YAML for loaded custom commands; can install to `~/.config/carapace/specs/` |
| `nul-genschema`     | `openapi.nu`               | Generate an OpenAPI 3.1 schema from all loaded custom commands |
| `cmd_stats`         | `cmd_stats.nu`             | Command usage statistics                                   |
| `twin format`       | `twin-tweaks.nu`           | Formatting for "This Week in Nu"                           |
| `generate-twin`     | `this_week_in_nu_weekly.nu`| Generate the weekly TWiN post                              |
| `nu`, `inspect-file`, `nonstdout`, `block-edit` | `nushell.nu` | Session helpers |
| `config update\|edit\|reset`, `config table mode`, `switch display output` | `nushell.nu` | Config manipulation |
| `self-destruct-hook`| `nushell.nu`               | Hook helper                                                |

Plus ~45 small helpers from `nu_defs.nu`, roughly grouped:

- **Navigation / dirs** — `cpwd`, `goto`, `goto-bash`, `which-cd`, `pwd-short`
- **Process** — `psn` (find a process), `killn` (kill by name)
- **Data shaping** — `column`, `column2`, `union`, `str repeat`, `switch`
  (switch/case), `group-list`, `skim`
- **Dates** — `ymd`, `dmy`, `md`, `agenda`, `semana`, `mes`, `countdown`
- **Session** — `rr` (reload config.nu and env.nu), `update-config`,
  `update-aliases`, `get-aliases`, `help my-commands`
- **Nu meta** — `nu-sloc` (source stats), `nu-png-plot`, `nu-downup-plot`, `gnu-plot`
- **External glue** — `supgrade` (Ubuntu upgrade), `mcx`, `openf`, `nujd`,
  `post_to_discord`, `addtogcal`, `mbitly`, `trans`, `7zfolders`, `7zmax`,
  `is-mounted`, `get-phone-number`, `gg`, `hab-dailies-done`, `git-push`

Many of these are personal-workflow glue that shells out to tools you may not
have. Read the definition before relying on one.

## Not re-exported by `mod.nu`

The majority of this directory. Reasons vary and are worth knowing:

| File                          | Why                                                              |
| ----------------------------- | ---------------------------------------------------------------- |
| `nu_deps.nu`                  | `export def main` — use `use lib/std/nu_deps.nu`                 |
| `nu_release.nu`               | same — `use lib/std/nu_release.nu`                               |
| `config.nu`                   | A Nushell *config file* (top-level `let`, absolute `use`), not a module |
| `init.nu`                     | Top-level env assignment in old syntax                           |
| `vars.nu`                     | Top-level record literals (keybinding config)                    |
| `modules.nu`                  | Keybinding config record — source from `config.nu` if wanted     |
| `commands_with_description.nu`| Top-level record literal                                         |
| `top_commands.nu`             | Script (bare pipeline)                                           |
| `dynamic-load.nu`             | **Broken on modern Nu** — `overlay list` with `in` is a type error on ≥ 0.95 |
| `utils.nu`                    | Depends on the external `argx` module                            |

```nu
use lib/std/nu_deps.nu
nu-deps            # publish ordering for Nushell crates, by dependency
```

`nu_deps` computes the order in which Nushell's own crates must be published.
`utils.nu` holds `convert-alias-file`, `alias-to-fn`, and `wrap-fn` if you do
have `argx`.
