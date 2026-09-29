#!/usr/bin/env nu
# Validation for the sys category: load every module, confirm the expected
# commands are exported, and smoke-test the read-only paths end to end.
# Run with:  nu --no-config-file /Users/joe/dev/nu_libs/lib/sys/validate.nu
#
# Gotchas this file works around, all hit while writing the category:
#   - closures cannot mutate an outer `mut`, so `check` returns a bool and the
#     results are tallied at the end
#   - `mut x = null` types x as `nothing` and then cannot be reassigned
#   - `null` is not a usable expression, so `(x != null)` will not parse
#   - nesting $"..." inside $"..." does not parse

# `use` requires literal paths, so no const interpolation here.
use /Users/joe/dev/nu_libs/lib/sys/sys-scan.nu *
use /Users/joe/dev/nu_libs/lib/sys/sys-triage.nu *
use /Users/joe/dev/nu_libs/lib/sys/sys-reap.nu *
use /Users/joe/dev/nu_libs/lib/sys/sys-disk.nu *
use /Users/joe/dev/nu_libs/lib/sys/sys-audit.nu *
use /Users/joe/dev/nu_libs/lib/sys/test-fixture.nu *
use /Users/joe/dev/nu_libs/lib/sys/disk-classify.nu *

def check [label: string, ok: bool] {
  # Keep the interpolation flat.
  let mark = (if $ok { "ok  " } else { "FAIL" })
  print $"($mark) ($label)"
  $ok
}

let names = (scope commands | get name)

mut results = []
$results = ($results | append (check "sys-scan exported" ("sys-scan" in $names)))
$results = ($results | append (check "sys-triage exported" ("sys-triage" in $names)))
$results = ($results | append (check "sys-reap exported" ("sys-reap" in $names)))
$results = ($results | append (check "sys-disk exported" ("sys-disk" in $names)))

print "--- scan + triage end to end (read-only) ---"
let scan = (sys-scan --no-footprint)
$results = ($results | append (check "scan returns groups" (($scan | get groups | length) > 0)))
$results = ($results | append (check "scan returns swap ctx" (($scan | get ctx | get swap_total_mb) > 0.0)))

let triage = ($scan | sys-triage)
$results = ($results | append (check "triage has findings" (($triage | get findings | length) > 0)))
$results = ($results | append (check "triage counts present" (($triage | get counts | columns | length) == 4)))
$results = ($results | append (check "triage has escalate flag" ("escalated" in ($triage | columns))))

print "--- reaper refuses its own ancestry ---"
let ppid = (ps | where pid == $nu.pid | first | get ppid)
let guard = (sys-reap --pids [$nu.pid $ppid] --exclude-self --dry-run)
$results = ($results | append (check "own ancestry refused" (($guard | get refused | length) == 2)))
$results = ($results | append (check "nothing would be signalled" (($guard | get survived | is-empty))))
$results = ($results | append (check "dry run signalled nothing" (($guard | get signalled | is-empty))))

print "--- reaper ignores an already-dead pid ---"
let dead = (sys-reap --pids [999999] --exclude-self --dry-run)
$results = ($results | append (check "dead pid yields no targets" (($dead | get survived | is-empty))))

print "--- SIGKILL is a separate, opt-in decision ---"
# The sys-usage invariant: "I approved a kill" must never silently become "I
# force-killed". The default path sends SIGTERM only, so `killed` must stay
# empty and `escalated` must be false unless --escalate was passed explicitly.
let term_only = (sys-reap --pids [999999] --exclude-self --dry-run)
$results = ($results | append (check "default path does not escalate" (($term_only | get escalated) == false)))
$results = ($results | append (check "default path force-kills nothing" (($term_only | get killed | is-empty))))

let opt_in = (sys-reap --pids [999999] --exclude-self --dry-run --escalate)
$results = ($results | append (check "--escalate is what sets escalated" (($opt_in | get escalated) == true)))

let reap_help = (
  ^nu --no-config-file -c "use /Users/joe/dev/nu_libs/lib/sys/sys-reap.nu *; sys-reap --help"
  | complete | get stdout
)
let esc_line = ($reap_help | lines | where {|l| $l | str contains "--escalate"} | first)
$results = ($results | append (check "--escalate help says it is off by default" ($esc_line | str contains "off by default")))

print "--- disk report (fixture tree) ---"
# Previously this scanned ~/dev/valerie, which is small enough that gdu
# returned zero rows, and both checks still passed: total_mb >= 0.0 holds for
# 0.0, and summary length == 4 was a constant from a hardcoded literal. The
# fixture makes these assert something.
let disk_fixture = (make-fixture --label "validate-fixture")
let disk = (sys-disk --root $disk_fixture --depth 3 --min-mb 0)
$results = ($results | append (check "disk reports rows" (($disk | get entries | length) > 0)))
$results = ($results | append (check "disk reports a total" (($disk | get total_mb) > 0.0)))
$results = ($results | append (check "disk summary matches declared categories" (
  (($disk | get summary | get category) == (category-names --profile "dev"))
)))
drop-fixture $disk_fixture

print "--- --only help names every category ---"
# The flag comment used to list rebuildable | git | source and omit `worktree`,
# which is the one category that must never be deleted blind. `complete` only
# wraps externals, so help text is captured from a nested nu process.
let help_out = (
  ^nu --no-config-file -c "use /Users/joe/dev/nu_libs/lib/sys/sys-disk.nu *; sys-disk --help"
  | complete | get stdout
)
let only_line = ($help_out | lines | where {|l| $l | str contains "--only"} | first)
$results = ($results | append (check "--only help mentions worktree" ($only_line | str contains "worktree")))
$results = ($results | append (check "--only help mentions rebuildable" ($only_line | str contains "rebuildable")))

print "--- a missing root must not look like an empty tree ---"
# Previously this returned total_mb 0.00 with a full four-row summary --
# indistinguishable from a real, genuinely empty directory, so a typo in --root
# produced a confident, wrong answer.
let missing = (
  ^nu --no-config-file -c "use /Users/joe/dev/nu_libs/lib/sys/sys-disk.nu *; sys-disk --root /Users/joe/dev/NO_SUCH_DIR_XYZ --depth 1 --min-mb 1"
  | complete
)
$results = ($results | append (check "missing root exits non-zero" (($missing.exit_code) != 0)))
$results = ($results | append (check "missing root says why" (
  (($missing.stdout | lines | append ($missing.stderr)) | str join "\n") | str contains "NO_SUCH_DIR_XYZ"
)))

print "--- unreadable paths are reported, not swallowed ---"
# gdu/du print "Operation not permitted" to stderr for macOS TCC-protected
# trees. Piping only stdout discarded them, so a scan could silently miss most
# of ~/Library and still report a confident total. Every denial must surface.
let denied = (sys-disk --root /Users/joe/Library/Containers --depth 1 --min-mb 0)
$results = ($results | append (check "disk has a skipped key" ("skipped" in ($denied | columns))))
$results = ($results | append (check "skipped is non-empty on a TCC tree" (($denied | get skipped | length) > 0)))
$results = ($results | append (check "skipped rows name a path" (
  ($denied | get skipped | first | get path | str length) > 0
)))

print "--- --exclude removes rows without touching the scan ---"
# A home-wide run wants the TCC-heavy trees dropped up front, not carried
# through the scan only to be filtered out of the report afterwards.
let libs = (sys-disk --root /Users/joe/Library --depth 1 --min-mb 0)
$results = ($results | append (check "disk accepts --exclude" (($libs | get skipped) != null)))
let pruned = (sys-disk --root /Users/joe/Library --depth 1 --min-mb 0 --exclude [Caches])
$results = ($results | append (check "excluded path is absent from entries" (
  ($pruned | get entries | where {|e| $e.path | str contains "Library/Caches"} | length) == 0
)))
$results = ($results | append (check "excluded path is recorded as skipped" (
  ($pruned | get skipped | any {|s| $s.reason == "excluded" and ($s.path | str contains "Library/Caches")})
)))

print "--- paths containing spaces survive parsing ---"
# gdu and du separate size from path with a TAB, but the parser split on
# whitespace, so '/Users/joe/Library/Application Support' was truncated to
# '/Users/joe/Library/Application'. That silently drops a large, real tree
# from any home-wide report.
let spaced = (sys-disk --root /Users/joe/Library --depth 1 --min-mb 0)
$results = ($results | append (check "a spaced path is parsed intact" (
  $spaced | get entries | any {|e| $e.path | str ends-with "Library/Application Support"}
)))
$results = ($results | append (check "no entry path is truncated at a space" (
  not ($spaced | get entries | any {|e| $e.path | str ends-with "Library/Application"})
)))

print "--- sys-audit: the home profile ---"
$results = ($results | append (check "sys-audit exported" ("sys-audit" in $names)))

let fixture = (make-fixture --label "audit-fixture")
let audited = (sys-audit --root $fixture --depth 2 --min-mb 0)
$results = ($results | append (check "audit returns rows" (($audited | get entries | length) > 0)))
$results = ($results | append (check "audit labels target/ rebuildable" (
  $audited | get entries | any {|e| ($e.path | str ends-with "proj/target") and $e.category == "rebuildable"}
)))
$results = ($results | append (check "audit labels .cache as cache" (
  $audited | get entries | any {|e| ($e.path | str ends-with "/.cache") and $e.category == "cache"}
)))
$results = ($results | append (check "audit leaves a plain directory as source" (
  $audited | get entries | any {|e| ($e.path | str ends-with "/notes") and $e.category == "source"}
)))
$results = ($results | append (check "audit never emits a dev-only category" (
  not ($audited | get entries | any {|e| $e.category in ["git" "worktree"]})
)))

print "--- the never-deletes contract is documented ---"
# The single most important property of both disk commands. If someone adds a
# --delete flag without reading this, the guard is a comment nobody else sees.
let audit_src = (open --raw /Users/joe/dev/nu_libs/lib/sys/sys-audit.nu)
$results = ($results | append (check "sys-audit header says it never deletes" (
  $audit_src | str downcase | str contains "never deletes"
)))
$results = ($results | append (check "sys-audit has no delete flag" (
  not ($audit_src | str contains "--delete")
)))
$results = ($results | append (check "sys-audit documents its cost" (
  $audit_src | str downcase | str contains "costs real time"
)))
$results = ($results | append (check "sys-audit documents what it cannot see" (
  $audit_src | str contains "TCC"
)))
# Omitting --root must resolve to the home directory, but proving that means a
# real ~-wide scan (~90s+), which is too slow for this script -- gdu stats every
# file even at --depth 0. So pin the field name instead: it is `home-dir` on
# nu 0.111, and `home-path` looks plausible enough to be a silent trap.
$results = ($results | append (check "sys-audit resolves home via home-dir" (
  $audit_src | str contains "$nu.home-dir"
)))
$results = ($results | append (check "sys-audit does not reference \$nu.home-path" (
  not ($audit_src | str contains "$nu.home-path")
)))
drop-fixture $fixture

let fails = ($results | where {|x| $x == false} | length)
print ""
if $fails == 0 {
  print "ALL CHECKS PASSED"
} else {
  print $"($fails) of ($results | length) checks failed"
  exit 1
}
