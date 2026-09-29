# sys — macOS system inspection: process memory, swap pressure, disk bloat
# Requires: macOS. `sys-scan`/`sys-triage` are read-only; `sys-reap` kills and
# refuses its own ancestry; `sys-disk` never deletes.
# Validate: nu --no-config-file lib/sys/validate.nu
# See the `sys-usage` skill for the workflow and the gotchas encoded here.

# All four are re-exported normally. The "load by file path, not glob" list in
# CLAUDE.md refers to files a category mod.nu deliberately OMITS -- glob
# re-export does not strip `export def main` (verified: `data/mod.nu` exports
# typeof.nu and `typeof` resolves through the glob, as do these four).
export use ./sys-scan.nu *
export use ./sys-triage.nu *
export use ./sys-reap.nu *
export use ./sys-disk.nu *
