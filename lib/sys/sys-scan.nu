#!/usr/bin/env nu
# Sample macOS process and memory state into structured records for triage.
#
# Groups `ps` by process name, then joins each group with an *instantaneous*
# reading from `top -l 2`, producing per-app records carrying resident size,
# physical footprint, live CPU, and the gap between the first two.
#
# Why instantaneous CPU: `ps` reports a lifetime CPU average, so an abandoned
# session and a busy one look identical. `top -l 2` discards its first sample
# (no prior reading to difference against) and the second is a real one-shot.
#
# Why two memory numbers: `ps` mem is RSS, which excludes pages already paged
# out. A Bun process holding 9.1 GB of swapped-out heap reports as ~54 MB via
# `ps`, which is why RSS-only triage misses the worst offender on the machine.
# `top`'s MEM column reflects real physical commitment, so the gap between the
# two is a swap-pressure signal available for free. `footprint -p` confirms it
# exactly but SUSPENDS the target while measuring, so it is opt-in and capped.
#
# Requires: macOS. Uses ps, top, sysctl, memory_pressure, and (optionally)
# footprint, which ships with the Xcode command line tools.
#
# Usage:
#   use ~/dev/nu_libs/lib/sys/sys-scan.nu *
#   sys-scan                      # confirm the 5 biggest swap-gap groups
#   sys-scan --no-footprint       # skip the slow confirming pass (fast)
#   sys-scan --footprint-top 15   # confirm more groups
#   sys-scan --no-ctx             # skip the machine-wide swap/pressure snapshot
#   sys-scan | sys-triage         # pipe straight into classification

# `top` renders MEM with mixed unit suffixes and a gauge direction marker:
# `6774M`, `4049K`, `3442M-`, `1719M+`. Stripping the suffix and reading the
# bare number as MB silently inflates every K-row by 1024x, so the unit has to
# be parsed and normalised.
def _to-mb [num: float, unit: string] {
  match ($unit | str upcase) {
    "K" => ($num / 1024.0)
    "M" => $num
    "G" => ($num * 1024.0)
    "T" => ($num * 1048576.0)
    _ => $num
  }
}

# Parse the last sample of `top -l 2` into a pid -> {cpu, phys_mb} lookup.
#
# Read via `complete | get stdout` because the raw stream can be classified as
# binary by downstream text commands (top emits ANSI gauge bytes).
#
# The line regex anchors on the RIGHT: command names contain spaces and are
# truncated to 16 chars, so positional splitting mis-reads every field of a row
# like `Comet Helper (Re`. Anchoring the numeric fields from the right and
# letting the command absorb the middle is the only stable parse.
def _live-cpu [] {
  let out = (^top -l 2 -n 400 -stats pid,command,cpu,mem | complete | get stdout)
  let ls = ($out | lines)

  # `top -l 2` prints a full table twice. Keep only the block after the final
  # header — the first sample has no prior reading to compute a delta from.
  let headers = ($ls | enumerate | where {|e| $e.item | str starts-with 'PID' })
  let block = (
    if ($headers | is-empty) {
      $ls
    } else {
      $ls | skip (($headers | last).index + 1)
    }
  )

  let re = '^\s*(?P<pid>\d+)\s+.*\s+(?P<cpu>[\d.]+)\s+(?P<num>[\d.]+)(?P<unit>[KMGT])(?P<dir>[+-]?)\s*$'

  let rows = (
    $block
    | each {|l| $l | parse -r $re}
    | flatten
    | each {|h| {
        pid: (try { $h.pid | into int } catch { 0 })
        cpu: (try { $h.cpu | into float } catch { 0.0 })
        phys_mb: (_to-mb (try { $h.num | into float } catch { 0.0 }) $h.unit)
      }}
    | where {|r| $r.pid > 0}
  )

  # NOTE: `reduce` takes the closure as (item, accumulator), NOT
  # (accumulator, item) -- getting this backwards makes the accumulator look
  # like the element and fails with a misleading "cannot find column" error.
  $rows | reduce --fold {} {|it, acc|
    $acc | upsert $"($it.pid)" { cpu: $it.cpu, phys_mb: $it.phys_mb }
  }
}

# Machine-wide swap and pressure snapshot.
def _ctx [] {
  let swap_raw = (try { ^sysctl -n vm.swapusage | str trim } catch { '' })
  let nums = (
    $swap_raw
    | parse -r 'total = (?P<total>[\d.]+)M\s+used = (?P<used>[\d.]+)M\s+free = (?P<free>[\d.]+)M'
    | first
    | default {}
  )

  # `str replace --regex` replaces only the FIRST match unless --all is passed,
  # so strip-digits style parsing silently leaves most of the line intact.
  # Capture the number with `parse -r` instead.
  let free_pct = (
    try {
      ^memory_pressure
      | complete
      | get stdout
      | lines
      | where {|l| $l | str contains 'System-wide memory free percentage'}
      | first
      | parse -r 'free percentage: (?P<pct>\d+)%'
      | first
      | get pct
      | into int
    }
    catch { -1 }
  )

  {
    swap_total_mb: (try { $nums.total | into float } catch { 0.0 })
    swap_used_mb: (try { $nums.used | into float } catch { 0.0 })
    swap_free_mb: (try { $nums.free | into float } catch { 0.0 })
    mem_free_pct: $free_pct
  }
}

# Exact `phys_footprint` in MB via the `footprint` tool; 0 on any failure (it
# needs permission for other users' processes). SLOW: suspends the target.
def _footprint-mb [pid: int] {
  let hits = (
    try {
      ^footprint -p $pid
      | complete
      | get stdout
      | lines
      | where {|l| $l | str contains 'phys_footprint: '}
    }
    catch { [] }
  )

  if ($hits | is-empty) {
    0
  } else {
    # Parenthesised: bare `try { } catch { }` in statement position leaves
    # `catch` to be parsed as its own command.
    (try {
      $hits | first | str replace -r '.*phys_footprint: ([0-9]+).*' '$1' | into int
    } catch { 0 })
  }
}

# [nu_lib] Sample process + memory state. Emits one record per process name.
export def main [
  --footprint-top: int = 5   # how many swap-gap leaders to confirm with `footprint`
  --no-footprint              # skip the slow confirming pass
  --no-ctx                    # skip the machine-wide swap/pressure snapshot
  --min-mb: int = 1           # drop groups below this resident size
] {
  let procs = (ps)
  let live = (_live-cpu)

  let groups = (
    $procs
    | group-by name
    | transpose name rows
    | each {|g|
        let pids = ($g.rows | get pid)
        let rss_mb = (($g.rows | get mem | math sum) / 1mb)

        let seen = ($pids | each {|pid| $live | get -o $"($pid)" | default { cpu: 0.0, phys_mb: 0.0 }})
        let phys_seen = ($seen | where {|s| $s.phys_mb > 0.0} | get phys_mb)
        let cpus = ($seen | where {|s| $s.cpu > 0.0} | get cpu)

        let phys_mb = (if ($phys_seen | is-empty) { 0.0 } else { $phys_seen | math sum })

        # Bound to a variable: a bare record literal at the tail of an `each`
        # closure is parsed as a closure and receives the pipeline input.
        let rec = {
          name: $g.name
          procs: ($g.rows | length)
          pids: $pids
          rss_mb: $rss_mb
          # Fall back to rss when `top` did not report this pid at all.
          phys_mb: (if $phys_mb > 0.0 { $phys_mb } else { $rss_mb })
          cpu_pct: (if ($cpus | is-empty) { 0.0 } else { $cpus | math avg })
          footprint_mb: 0
        }
        $rec
      }
    | where {|g| $g.rss_mb >= $min_mb}
    | each {|g|
        $g | upsert swap_gap_mb ([($g.phys_mb - $g.rss_mb) 0.0] | math max)
      }
  )

  # Confirm the biggest swap-gap offenders exactly. Ranked by gap rather than
  # RSS, because a process holding a large swapped-out heap can have a tiny RSS
  # and would never top an RSS-ranked list.
  let confirmed = (
    if $no_footprint or $footprint_top <= 0 {
      []
    } else {
      $groups
      | sort-by --reverse swap_gap_mb
      | where {|g| $g.swap_gap_mb > 0.0}
      | first $footprint_top
      | each {|g| { name: $g.name, footprint_mb: (_footprint-mb ($g.pids | first)) } }
    }
  )

  let groups = (
    if ($confirmed | is-empty) {
      $groups
    } else {
      $groups | each {|g|
        let hit = ($confirmed | where {|c| $c.name == $g.name} | first)
        if $hit == null {
          $g
        } else {
          $g | upsert footprint_mb $hit.footprint_mb
        }
      }
    }
  )

  {
    groups: $groups
    ctx: (if $no_ctx { {} } else { _ctx })
  }
}
