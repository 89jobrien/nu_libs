#!/usr/bin/env nu
# Classify `sys-scan` output into ranked findings. Reads the scan record on
# stdin; never kills anything. Use `sys-reap` for that, and only after a human
# has seen the findings this produces.
#
# Four signals, each earning its place:
#
#   swap-bloated  phys >> rss. The process holds a large swapped-out heap that
#                `ps`/RSS reporting hides completely. Found a 9.1 GB Bun heap
#                reading as 54 MB via RSS.
#   idle hog      large resident but ~zero instantaneous CPU. Needs `top -l 2`
#                rather than `ps`, whose CPU column is a lifetime average that
#                makes abandoned and busy sessions look identical.
#   fan-out       many processes under one name. Renderer/executor storms.
#   escalation    swap total above the warn threshold. Free RAM percentage is
#                actively misleading here: a machine can sit at 60% free RAM
#                while holding 14 GB of swap, which is the number that matters.
#
# Requires: macOS, and sys-scan for input.
#
# Usage:
#   use ~/dev/nu_libs/lib/sys/sys-triage.nu *
#   sys-scan | sys-triage
#   sys-scan | sys-triage --idle-mb 1024 --fanout 40   # stricter
#   sys-scan | sys-triage --only suspect

# [nu_lib] Classify scan records. Consumes a `sys-scan` record on stdin.
export def main [
  --swap-warn: float = 80.0   # swap-used % that escalates the whole report
  --idle-mb: float = 512.0    # resident MB above which low CPU is suspicious
  --idle-cpu: float = 1.0     # instantaneous CPU % at or below which = idle
  --fanout: int = 25          # process count at or above which fan-out is flagged
  --gap-ratio: float = 2.0    # phys/rss ratio at or above which = swap-bloated
  --gap-mb: float = 256.0     # minimum absolute gap MB, to keep small ratios quiet
  --only: string = ""         # restrict output: suspect | review | fine
] {
  let scan = $in
  let groups = ($scan | get -o groups | default [])
  let ctx = ($scan | get -o ctx | default {})

  let swap_used = ($ctx | get -o swap_used_mb | default 0.0)
  let swap_total = ($ctx | get -o swap_total_mb | default 0.0)
  let swap_pct = (if $swap_total > 0.0 { ($swap_used / $swap_total) * 100.0 } else { 0.0 })

  let findings = (
    $groups
    | each {|g|
        let rss = $g.rss_mb
        let phys = $g.phys_mb
        let gap = ($g | get -o swap_gap_mb | default 0.0)
        let cpu = ($g | get -o cpu_pct | default 0.0)
        let procs = ($g | get -o procs | default 1)
        let ratio = (if $rss > 0.0 { $phys / $rss } else { 0.0 })

        let kind = (
          if $gap >= $gap_mb and $ratio >= $gap_ratio {
            "swap-bloated"
          } else if $rss >= $idle_mb and $cpu <= $idle_cpu {
            "idle-hog"
          } else if $procs >= $fanout {
            "fan-out"
          } else {
            "ok"
          }
        )

        let reason = (
          if $kind == "swap-bloated" {
            $"swap-bloated: ($phys | math round) MB physical vs ($rss | math round) MB resident \(ratio * 100 | math round | into int)% ratio, ($gap | math round) MB held in swap"
          } else if $kind == "idle-hog" {
            $"idle hog: ($rss | math round) MB resident at ($cpu) % instantaneous CPU"
          } else if $kind == "fan-out" {
            $"fan-out: ($procs) processes under one name"
          } else {
            $"ok: ($rss | math round) MB resident, ($cpu) % CPU, ($procs) proc\(s\)"
          }
        )

        # Bound to a variable: a bare record literal at the tail of an `each`
        # closure is parsed as a closure and receives the pipeline input.
        let rec = {
          kind: $kind
          name: $g.name
          reason: $reason
          pids: ($g | get -o pids | default [])
          procs: $procs
          rss_mb: $rss
          phys_mb: $phys
          swap_gap_mb: $gap
          cpu_pct: $cpu
          footprint_mb: ($g | get -o footprint_mb | default 0)
          # Killing returns resident pages to RAM immediately. The swapped
          # portion is only released back into the pool lazily, and freeing it
          # reduces swap pressure rather than adding headroom.
          reclaim_rss_mb: (if $kind != "ok" { $rss } else { 0.0 })
          reclaim_swap_mb: (if $kind != "ok" { $gap } else { 0.0 })
        }
        $rec
      }
  )

  let findings = (if $only == "" { $findings } else { $findings | where {|f| $f.kind == $only}})

  # Rank by reclaimable swap first. A swap-bloated process usually has a small
  # resident set, so ranking by RSS would bury exactly the ones worth acting
  # on. Triage is a shortlist, not a kill list — see the SKILL.md workflow.
  let ranked = ($findings | sort-by --reverse reclaim_swap_mb)

  let escalated = ($swap_pct >= $swap_warn)
  let escalate_reason = (
    if $escalated {
      $"swap at ($swap_pct | math round) % of ($swap_total | math round) MB \(above threshold ($swap_warn) %\) — resident memory percentage is not the real signal here"
    } else {
      ""
    }
  )

  let flagged = ($findings | where {|f| $f.kind != "ok"})

  {
    escalated: $escalated
    escalate_reason: $escalate_reason
    swap_used_pct: $swap_pct
    findings: $ranked
    counts: {
      swap-bloated: ($flagged | where {|f| $f.kind == "swap-bloated"} | length)
      idle-hog: ($flagged | where {|f| $f.kind == "idle-hog"} | length)
      fan-out: ($flagged | where {|f| $f.kind == "fan-out"} | length)
      ok: ($findings | where {|f| $f.kind == "ok"} | length)
    }
    reclaim_rss_mb: (($flagged | get reclaim_rss_mb | math sum))
    reclaim_swap_mb: (($flagged | get reclaim_swap_mb | math sum))
    ctx: $ctx
  }
}
