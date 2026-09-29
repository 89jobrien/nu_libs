#!/usr/bin/env nu
# Report on disk bloat across $HOME, categorised by whether the space is
# regenerable cache, a VM or container image, per-application state, or real
# data. NEVER DELETES ANYTHING.
#
# The question this answers is "should we clean anything from ~ ?", which
# `sys-disk` cannot. That command is scoped to a dev tree and knows four
# categories tuned for Rust and JS repos. Pointed at $HOME it calls
# `~/Library/Caches`, `~/.cache` and `~/.minibox` all `source`, labelling tens
# of gigabytes of regenerable space as if it were authored work.
#
# Deliberately one filesystem pass, same as `sys-disk`: a single
# `gdu -d <depth>` run classified by path segment afterwards, rather than a
# size pass followed by a second walk. Two passes would double the cost of an
# already slow scan.
#
# COSTS REAL TIME. A depth-1 scan of ~/dev takes roughly 90-135s. This is
# slower still, because the home tree holds VM images and package caches that
# the dev tree does not -- `~/.minibox` alone is tens of gigabytes. Prefer
# `--depth 1`; go deeper only to answer a specific question.
#
# WHAT IT WILL NOT SEE: macOS TCC denies reading large parts of ~/Library
# (Caches, Containers, Application Support) and ~/.Trash. Those paths are
# reported in the `skipped` list rather than silently omitted, so a short
# skipped list means a complete scan and a long one means the total is a floor,
# not a measurement.
#
# Requires: macOS, and gdu or du.
#
# Usage:
#   use ~/dev/nu_libs/lib/sys/sys-audit.nu *
#   sys-audit                                # depth 1 across $HOME
#   sys-audit --root /Users/joe/Library      # a subtree
#   sys-audit --only cache                   # just the regenerable caches
#   sys-audit --only rebuildable --min-mb 0  # everything a rebuild would restore
#   sys-audit --depth 2 --exclude [.minibox] # look inside, but skip VM images

# Classification is shared with sys-disk so the two commands cannot drift.
use ./disk-classify.nu *

# Substring match: `--exclude .minibox` drops any path containing it.
def _excluded [path: string, patterns: list<string>] {
  $patterns | any {|x| $path | str contains $x}
}

# [nu_lib] Home-wide categorised disk report. Never deletes.
export def main [
  --root: path                     # tree to scan; defaults to your home directory
  --profile: string = "home"       # classification profile
  --depth: int = 1                 # 1 = per top-level directory
  --top: int = 20                  # how many rows per category
  --min-mb: int = 100              # ignore entries below this size
  --only: string = ""              # restrict: cache | rebuildable | vm | container | archive | media | appdata | source
  --exclude: list<string> = [Library/Containers "Library/Application Support/CloudDocs" .minibox]
                                  # path substrings to drop from the report
] {
  # `const` cannot reference `$env`, so the home default is resolved at
  # runtime. The field is `home-dir` on nu 0.111; `home-path` looks plausible
  # but does not exist, and reading it fails only when --root is omitted.
  let root = (if $root == null { $nu.home-dir } else { $root })

  if not ($root | path exists) {
    error make { msg: $"sys-audit: root does not exist: ($root)" }
  }

  let has_gdu = (which gdu | is-not-empty)

  # `complete` only works attached directly to an external call, so it lives
  # inside each branch rather than on the `if` expression. Keep the whole
  # record: stderr carries the TCC denials that would otherwise be dropped,
  # making a partial scan look like a complete one.
  # gdu defaults to 1K blocks like du, so ask for exact bytes with -B1.
  let scan = (
    if $has_gdu {
      ^gdu -B1 -d $depth $root | complete
    } else {
      print "gdu not found, falling back to du (much slower)"
      ^du -k -d $depth $root | complete
    }
  )

  let skipped = (
    $scan
    | get stderr
    | lines
    | where {|l| ($l | str trim) != "" }
    | parse --regex '(?P<denied_path>.+): (?P<why>Operation not permitted|Permission denied)$'
    | each {|m|
        let p = (
          $m.denied_path
          | str replace --all --regex '^gdu: cannot read directory ' ''
          | str replace --all --regex '^du: ' ''
          | str replace --all --regex "^'" ''
          | str replace --all --regex "'$" ''
          | str trim
        )
        { path: $p, reason: ($m.why | str downcase) }
      }
  )

  let rows = (
    $scan
    | get stdout
    | lines
    | where {|l| ($l | str trim) != "" }
    | each {|l|
        # gdu and du separate size from path with a TAB. Splitting on
        # whitespace truncates any path with a space in it, which silently
        # drops `~/Library/Application Support` from the report.
        let t = ($l | str trim --right)
        let tabbed = ($t | split row (char tab) | where {|p| ($p | str length) > 0 })
        let parts = (if ($tabbed | length) >= 2 { $tabbed } else { $t | split row -r '\s+' | where {|p| ($p | str length) > 0 } })
        if ($parts | length) < 2 {
          null
        } else {
          let kb = (try { $parts | get 0 | str trim | into float } catch { 0.0 })
          let path = ($parts | get 1 | str trim)
          let mb = (if $has_gdu { $kb / 1048576.0 } else { $kb / 1024.0 })
          { path: $path, mb: $mb }
        }
      }
    | where {|r| $r != null}
    | where {|r| $r.mb >= $min_mb}
  )

  # Drop the root's own total row so it is not counted as a child of itself.
  let root_norm = ($root | str trim)
  let rows = ($rows | where {|r| $r.path != $root_norm })

  # Exclusions land in `skipped`, not nowhere: an exclusion is a choice and
  # stays visible in the report.
  let dropped = ($rows | where {|r| _excluded $r.path $exclude } | each {|r|
    { path: $r.path, reason: "excluded" }
  })
  let rows = ($rows | where {|r| not (_excluded $r.path $exclude) })
  let skipped = ($skipped | append $dropped)

  let rows = (
    $rows
    | each {|r|
        let cat = (classify-disk-path --path $r.path --profile $profile)
        { category: $cat, path: $r.path, mb: $r.mb }
      }
  )

  let rows = (if $only == "" { $rows } else { $rows | where {|r| $r.category == $only} })

  # `math sum` errors on an empty list, which is a legitimate result here.
  let total_mb = (if ($rows | is-empty) { 0.0 } else { $rows | get mb | math sum })

  let summary = (
    (category-names --profile $profile) | each {|c|
      let in_cat = ($rows | where {|r| $r.category == $c})
      {
        category: $c
        count: ($in_cat | length)
        total_mb: (if ($in_cat | is-empty) { 0.0 } else { $in_cat | get mb | math sum })
      }
    }
  )

  {
    root: $root
    profile: $profile
    depth: $depth
    tool: (if $has_gdu { "gdu" } else { "du" })
    total_mb: $total_mb
    skipped_count: ($skipped | length)
    skipped: $skipped
    summary: $summary
    entries: ($rows | sort-by --reverse mb | first $top)
  }
}
