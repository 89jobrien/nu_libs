# std — Nu ecosystem: config, init, modules, release tooling, utilities
# Files with `export def main` (nu_deps, nu_release) must be used directly:
#   use lib/std/nu_deps.nu
#   use lib/std/nu_release.nu
# modules.nu is a keybinding config record, not a module — source it in config.nu if needed

export use ./nu_defs.nu *
# config.nu is a nushell config file (top-level `let` + absolute `use`), not a module
# init.nu uses top-level env assignment (old syntax), not suitable as a module
# vars.nu contains top-level record literals (keybinding config), not a module
# commands_with_description.nu contains top-level record literal, not a module
# top_commands.nu is a script (bare pipeline), use directly
export use ./cmd_stats.nu *
export use ./twin-tweaks.nu *
# dynamic-load.nu uses `overlay list` with `in` operator (type error in nu >= 0.95), use directly if needed
# utils.nu depends on `argx` external module, use directly if argx is installed
export use ./nushell.nu *
export use ./this_week_in_nu_weekly.nu *
export use ./openapi.nu *
export use ./carapace.nu *
