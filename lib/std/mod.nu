# std — Nu ecosystem: config, init, modules, release tooling, utilities
# Files with `export def main` (nu_deps, nu_release) must be used directly:
#   use lib/std/nu_deps.nu
#   use lib/std/nu_release.nu

export use ./nu_defs.nu *
export use ./modules.nu *
export use ./config.nu *
export use ./init.nu *
export use ./vars.nu *
export use ./commands_with_description.nu *
export use ./top_commands.nu *
export use ./cmd_stats.nu *
export use ./twin-tweaks.nu *
export use ./dynamic-load.nu *
export use ./utils.nu *
export use ./nushell.nu *
export use ./this_week_in_nu_weekly.nu *
