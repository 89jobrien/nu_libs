#!/usr/bin/env nu
# Synthetic directory tree for the sys validate scripts.
#
# The disk checks used to run against real repositories, which made them
# vacuous: `valerie` is tiny enough that gdu returned zero rows, yet
# `total_mb >= 0.0` and `summary | length == 4` both passed. A fixture with
# known contents turns "the plumbing runs" into "the rows are classified
# correctly".
#
# Pure helpers, no `export def main`, so it is safe to `use` from both
# validate.nu and validate-classify.nu. Deliberately NOT re-exported from
# lib/sys/mod.nu: this is test scaffolding, not a user command.

# Directory names deliberately chosen to exercise the precedence order in
# disk-classify.nu, including the case that must never be mislabelled: a
# worktree's own target/ is real work, not rebuildable.
const FIXTURE_DIRS = [
  proj/target
  proj/.git
  proj/src
  worktrees/w1/target
  cache
  .cache
  notes
  "My Notes"
]

# [nu_lib] Build a fixture tree and return its root path.
export def make-fixture [--label: string = "sys-fixture"] {
  # `mktemp -d` rather than $nu.temp-path, which does not exist in nu 0.111.
  let root = (^mktemp -d -t $label | str trim)

  for d in $FIXTURE_DIRS {
    ^mkdir -p ($root | path join $d)
  }

  # Enough bytes that every directory clears a --min-mb 0 threshold, and the
  # space-bearing name proves the tab-splitting parser works.
  for d in $FIXTURE_DIRS {
    let f = ($root | path join $d | path join "blob.bin")
    "x" | save --force $f
  }
  "notes" | save --force ($root | path join "notes.md")

  $root
}

# [nu_lib] Remove a fixture tree. Safe to call twice.
export def drop-fixture [root: string] {
  if ($root | path exists) {
    ^rm -rf $root
  }
}
