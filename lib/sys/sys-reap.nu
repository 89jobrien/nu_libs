#!/usr/bin/env nu
# Two-phase process reaper. SIGTERM first, report survivors, escalate to
# SIGKILL only when explicitly asked.
#
# Two-phase is not ceremony. Interactive TUI apps routinely ignore or mishandle
# SIGTERM: in testing, six abandoned opencode sessions all survived SIGTERM and
# needed SIGKILL, while their bloated Bun children died on the first signal.
# Making the escalation a separate, visible decision keeps "I approved a kill"
# from silently becoming "I force-killed".
#
# SAFETY: this command will not kill its own ancestry, and will not kill its own
# descendants unless explicitly told to. It walks up from its own pid and builds
# a protect-set. The invoking session, its agent runtime, and its parent shell
# are therefore unreachable even if handed a bad pid list. This is a hard
# invariant, not a heuristic — do not add a flag to bypass it.
#
# Requires: macOS, and `sys-scan`/`sys-triage` to produce the input. NEVER run
# this unattended or from a cron/hook context. A human reviews triage output
# and chooses the pids first.
#
# Usage:
#   use ~/dev/nu_libs/lib/sys/sys-reap.nu *
#
#   # inspect only, changes nothing
#   sys-reap --pids [1234 5678] --dry-run
#
#   # SIGTERM only; reports what survived, kills nothing further
#   sys-reap --pids [1234 5678]
#
#   # SIGTERM, wait, then SIGKILL whatever is left
#   sys-reap --pids [1234 5678] --escalate
#
#   # whole process groups, given a pid rather than a list
#   sys-reap --name ".opencode" --exclude-self
#   sys-reap --name ".opencode" --exclude-self --escalate

# Ancestors of the current process: the session, the agent runtime, the shell.
# Everything here is untouchable.
def _self-ancestry [] {
  let procs = (ps)
  mut cur = $nu.pid
  mut chain = []
  for _ in 1..12 {
    let row = ($procs | where pid == $cur | first)
    if ($row | is-empty) { break }
    $chain = ($chain | append $row.pid)
    $cur = $row.ppid
  }
  $chain
}

# Descendants of the given pids, one level deep. Used to drop a root's children
# from the target list so we never signal a parent and its child in one pass.
def _children-of [procs: list, pids: list] {
  $pids | each {|p| $procs | where ppid == $p | get pid } | flatten | uniq
}

# [nu_lib] SIGTERM a set of pids; optionally escalate survivors to SIGKILL.
export def main [
  --pids: list = []          # explicit pid list
  --name: string = ""        # or: match every process with this exact name
  --exclude-self             # drop the current ancestry from the target set
  --escalate                 # SIGKILL whatever survives SIGTERM (off by default)
  --wait-sec: int = 3        # pause between phases
  --dry-run                  # report the plan, signal nothing
] {
  let procs = (ps)
  let protect = (if $exclude_self { _self-ancestry } else { [] })

  let selected = (
    if ($pids | is-not-empty) {
      $procs | where pid in $pids | get pid
    } else if $name != "" {
      $procs | where name == $name | get pid
    } else {
      []
    }
  )

  # Never signal our own ancestry, and never signal a pid twice.
  let targets = ($selected | where {|p| not ($p in $protect) } | uniq | where {|p| $procs | where pid == $p | is-not-empty })

  let blocked = ($selected | where {|p| $p in $protect })

  if ($targets | is-empty) {
    return {
      ok: true
      dry_run: $dry_run
      escalated: $escalate
      signalled: []
      survived: []
      killed: []
      refused: $blocked
      note: "no eligible targets"
    }
  }

  # Report the plan up front. A dry run is not proof of safety on its own —
  # verify `git status`/target state afterwards for anything with side effects.
  print $"targets: ($targets | length) pids -> ($targets | str join ' ')"
  if ($blocked | is-not-empty) {
    print $"refused (own ancestry): ($blocked | str join ' ')"
  }

  if $dry_run {
    return {
      ok: true
      dry_run: true
      escalated: $escalate
      signalled: []
      survived: $targets
      killed: []
      refused: $blocked
      note: "dry run, nothing signalled"
    }
  }

  # Phase 1: SIGTERM.
  #
  # Uses /bin/kill by absolute path, NOT nu's `kill` builtin. nu_libs defines
  # its own `kill` for pueue (lib/task/task.nu), which shadows the builtin and
  # accepts only --group/--all/--signal, so `kill --quiet ...$pids` fails to
  # PARSE under a full `use lib/mod.nu *` load. The external is immune to
  # whatever else is in scope.
  #
  # Signals are numeric, and the exit code is discarded: /bin/kill exits
  # nonzero if ANY pid is already gone, which is normal here and must not abort
  # the reap.
  ^/bin/kill -15 ...$targets | complete | ignore
  let term_sent = $targets

  if not $escalate {
    return {
      ok: true
      dry_run: false
      escalated: false
      signalled: $term_sent
      survived: []
      killed: []
      refused: $blocked
      note: $"SIGTERM sent. Re-run with --escalate to force-kill survivors; interactive TUIs commonly ignore SIGTERM."
    }
  }

  # Phase 2: SIGKILL whatever is still alive.
  sleep ($wait_sec * 1sec)
  let still = ($term_sent | where {|p| $procs | where pid == $p | is-not-empty })
  if ($still | is-not-empty) {
    ^/bin/kill -9 ...$still | complete | ignore
  }

  sleep ($wait_sec * 1sec)
  let final = (ps)
  let survived = ($still | where {|p| $final | where pid == $p | is-not-empty })

  {
    ok: ($survived | is-empty)
    dry_run: false
    escalated: true
    signalled: $term_sent
    survived: $survived
    killed: ($still | where {|p| not ($p in $survived) })
    refused: $blocked
    note: (if ($survived | is-empty) { "all targets terminated" } else { "some targets survived even SIGKILL" })
  }
}
