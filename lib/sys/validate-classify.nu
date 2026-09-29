#!/usr/bin/env nu
# Classification tests for lib/sys/disk-classify.nu.
#
# These exist because the classifier used to be a closure inside `sys-disk`'s
# `main`, which made it impossible to call from a test. The two disk assertions
# in validate.nu passed against an EMPTY tree, because `total_mb >= 0.0` is true
# for 0.0 and `summary | length == 4` is a constant. A pure function can be
# asserted directly.
#
# Run: nu --no-config-file /Users/joe/dev/nu_libs/lib/sys/validate-classify.nu
#
# Gotchas: closures cannot mutate an outer `mut`, so `each` RETURNS the bool
# list rather than appending into a `mut`. Nesting $"..." inside $"..." does not
# parse.

use /Users/joe/dev/nu_libs/lib/sys/disk-classify.nu *

def check [label: string, ok: bool] {
  # Keep the interpolation flat.
  let mark = (if $ok { "ok  " } else { "FAIL" })
  print $"($mark) ($label)"
  $ok
}

let cases = [
  { path: "/x/a/.git", profile: "dev", want: "git" }
  { path: "/x/a/target", profile: "dev", want: "rebuildable" }
  { path: "/x/a/src", profile: "dev", want: "source" }
  { path: "/x/a/node_modules", profile: "dev", want: "rebuildable" }
  # A worktree's own target/ is REAL work, never rebuildable. This is the
  # safety property the sys-disk inline comment claimed but nothing asserted.
  { path: "/x/worktrees/a/target", profile: "dev", want: "worktree" }
  { path: "/x/.worktrees/a", profile: "dev", want: "worktree" }
  # Home profile. .cache must be `cache`, not `rebuildable`: the OS regenerates
  # it on next use, whereas a build dir needs a build to come back.
  { path: "/Users/joe/.cache", profile: "home", want: "cache" }
  { path: "/Users/joe/Library/Caches", profile: "home", want: "cache" }
  { path: "/Users/joe/.npm", profile: "home", want: "cache" }
  { path: "/Users/joe/.minibox", profile: "home", want: "vm" }
  { path: "/Users/joe/.docker", profile: "home", want: "container" }
  { path: "/Users/joe/Movies", profile: "home", want: "media" }
  { path: "/Users/joe/Downloads/thing.dmg", profile: "home", want: "archive" }
  { path: "/Users/joe/Library/Application Support/Thing", profile: "home", want: "appdata" }
  { path: "/Users/joe/dev/crux/target", profile: "home", want: "rebuildable" }
  { path: "/Users/joe/Documents", profile: "home", want: "source" }
  # Home profile has no `git`/`worktree` categories, so repo metadata is source.
  { path: "/Users/joe/dev/crux/.git", profile: "home", want: "source" }
]

print "--- pure classification (no filesystem access) ---"
let case_results = ($cases | each {|c|
  let got = (classify-disk-path --path $c.path --profile $c.profile)
  check $"($c.profile): ($c.path) -> ($c.want)" ($got == $c.want)
})

print "--- category lists ---"
let dev_cats = (category-names --profile "dev")
let home_cats = (category-names --profile "home")
# Every category the classifier can emit must be in the declared list, or the
# summary silently under-reports.
let emitted = ($cases | each {|c| classify-disk-path --path $c.path --profile $c.profile})
let cat_results = [
  (check "dev profile has four categories" (($dev_cats | length) == 4))
  (check "dev profile keeps git" ("git" in $dev_cats))
  (check "dev profile keeps worktree" ("worktree" in $dev_cats))
  (check "home profile has eight categories" (($home_cats | length) == 8))
  (check "home profile has no worktree" (not ("worktree" in $home_cats)))
  (check "classifier never emits an undeclared category" ($emitted | all {|c| $c in ($dev_cats | append $home_cats)}))
]

# Guard against the exact regression this refactor removed. The category list
# used to be hardcoded in TWO places in sys-disk.nu -- the if/else chain and the
# summary literal -- so a category could be classified but never summarised.
# Task 8 adds the behavioural fixture that proves real rows classify; this
# assertion is what stops the duplication coming back.
print "--- no duplicated category vocabulary ---"
let src = (open --raw /Users/joe/dev/nu_libs/lib/sys/sys-disk.nu)
let dedup_results = [
  (check "sys-disk does not redeclare REBUILDABLE" (not ($src | str contains "const REBUILDABLE")))
  (check "sys-disk does not hardcode the category list" (
    not ($src | str contains "[\"rebuildable\" \"worktree\" \"git\" \"source\"]")
  ))
  (check "sys-disk calls the shared classifier" ($src | str contains "classify-disk-path"))
  (check "sys-disk uses the shared category list" ($src | str contains "category-names"))
]

let results = ($case_results | append $cat_results | append $dedup_results)

let fails = ($results | where {|x| $x == false} | length)
print ""
if $fails == 0 {
  print "ALL CLASSIFY CHECKS PASSED"
} else {
  print $"($fails) of ($results | length) classify checks failed"
  exit 1
}
