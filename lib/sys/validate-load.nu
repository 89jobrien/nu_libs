#!/usr/bin/env nu
# Second validation pass: exercise the sys category the way an interactive shell
# actually loads it -- via `use lib/mod.nu *` rather than by file path.
#
# This exists because of a real, load-breaking bug. `lib/task/task.nu` exports
# `kill` for pueue, which shadows nu's builtin `kill`. Because command
# resolution happens at parse time, `sys-reap` calling `kill --quiet ...$pids`
# did not merely misbehave -- the module failed to PARSE, so the entire nu_libs
# load aborted. Loading by file path (as validate.nu does) never exercises this.
#
# Simply reaching the end of this file is itself the regression guard: if any
# sys module fails to parse under a full load, this script never runs.
#
# Run with:  nu --no-config-file lib/sys/validate-load.nu

use /Users/joe/dev/nu_libs/lib/mod.nu *

mut results = []

def check [label: string, ok: bool] {
  let mark = (if $ok { "ok  " } else { "FAIL" })
  print $"($mark) ($label)"
  $ok
}

let want = ["sys-scan" "sys-triage" "sys-reap" "sys-disk"]
let have = (scope commands | get name)
$results = ($results | append (check "all four commands visible" ($want | all {|n| $n in $have})))

let cols = (ps | columns)
let need = ["pid" "ppid" "name" "mem"]
$results = ($results | append (check "ps exposes pid/ppid/name/mem" ($need | all {|c| $c in $cols})))

let scan = (sys-scan --no-footprint --no-ctx)
$results = ($results | append (check "scan runs under full load" (($scan | get groups | length) > 0)))

let t = ($scan | sys-triage)
$results = ($results | append (check "triage runs under full load" (($t | get findings | length) > 0)))

let ppid = (ps | where pid == $nu.pid | first | get ppid)
let guard = (sys-reap --pids [$nu.pid $ppid] --exclude-self --dry-run)
let refused = ($guard | get refused | length)
$results = ($results | append (check "reaper refuses own ancestry under full load" ($refused == 2)))
let would = ($guard | get survived | length)
$results = ($results | append (check "reaper signals nothing under full load" ($would == 0)))

let disk = (sys-disk --root /Users/joe/dev/valerie --depth 1 --min-mb 1)
let cats = ($disk | get summary | length)
$results = ($results | append (check "disk runs under full load" ($cats == 4)))

let fails = ($results | where {|x| $x == false} | length)
print ""
if $fails == 0 {
  print "ALL FULL-LOAD CHECKS PASSED"
} else {
  print $"($fails) of ($results | length) full-load checks failed"
  exit 1
}
