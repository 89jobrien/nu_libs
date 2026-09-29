#!/usr/bin/env nu
# Report on-disk bloat under a directory tree, categorised by whether the space
# is cheaply rebuildable, git overhead, or actual source. Report-only: this
# command never deletes anything.
#
# Deliberately one filesystem pass. A naive implementation runs a size scan and
# then a second walk to classify, which doubles the cost; instead a single
# `gdu -d <depth>` run is classified by path segment afterwards.
#
# COSTS REAL TIME. A depth-1 scan of ~/dev takes roughly 90-135s because it
# must stat every file in every Rust `target/` and `node_modules/`. Prefer
# `--depth 1` for "which project is the hog"; go deeper only to answer a
# specific question. Uses `gdu` (parallel) when present, since plain `du`
# exceeds two minutes on the same tree.
#
# Requires: macOS, and gdu or du.
#
# Usage:
#   use ~/dev/nu_libs/lib/sys/sys-disk.nu *
#   sys-disk                          # depth 1 under ~/dev, top 20
#   sys-disk --root /Users/joe/dev/crux --depth 2
#   sys-disk --only rebuildable       # just the safely-regenerable space
#   sys-disk --min-mb 500            # ignore anything under 500 MB

# Classification lives in disk-classify.nu so it can be tested without a
# filesystem. This file stays I/O-only: one gdu pass, then classify the rows.
use ./disk-classify.nu *

# [nu_lib] Categorised disk report. Never deletes.
export def main [
  --root: path = "/Users/joe/dev"   # tree to scan
  --depth: int = 1                  # 1 = per top-level project
  --top: int = 20                   # how many rows per category
  --min-mb: int = 100               # ignore entries below this size
  --only: string = ""               # restrict: rebuildable | git | source
] {
  let has_gdu = (which gdu | is-not-empty)

  # `complete` only works when attached directly to an external call, so it
  # lives inside each branch rather than on the `if` expression.
  # gdu defaults to 1K blocks like du, so ask for exact bytes with -B1 rather
  # than guessing the unit from the number's magnitude.
  let out = (
    if $has_gdu {
      ^gdu -B1 -d $depth $root | complete | get stdout
    } else {
      print "gdu not found, falling back to du (much slower)"
      ^du -k -d $depth $root | complete | get stdout
    }
  )

  let rows = (
    $out
    | lines
    | where {|l| ($l | str trim) != "" }
    | each {|l|
        let parts = ($l | str trim | split row -r '\s+' | where {|p| ($p | str length) > 0})
        if ($parts | length) < 2 {
          null
        } else {
          let kb = (try { $parts | get 0 | into float } catch { 0.0 })
          let path = ($parts | get 1 | str trim)
          # The `apparent-size` flag reports bytes for gdu; du reports KB.
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

  let rows = (
    $rows
    | each {|r|
        let cat = (classify-disk-path --path $r.path --profile "dev")
        let rec = { category: $cat, path: $r.path, mb: $r.mb }
        $rec
      }
  )

  let rows = (if $only == "" { $rows } else { $rows | where {|r| $r.category == $only} })

  # `math sum` errors on an empty list, which is a legitimate result here.
  let total_mb = (if ($rows | is-empty) { 0.0 } else { $rows | get mb | math sum })

  let summary = (
    (category-names --profile "dev") | each {|c|
      let in_cat = ($rows | where {|r| $r.category == $c})
      let rec = {
        category: $c
        count: ($in_cat | length)
        total_mb: (if ($in_cat | is-empty) { 0.0 } else { $in_cat | get mb | math sum })
      }
      $rec
    }
  )

  {
    root: $root
    depth: $depth
    tool: (if $has_gdu { "gdu" } else { "du" })
    total_mb: $total_mb
    summary: $summary
    entries: ($rows | sort-by --reverse mb | first $top)
  }
}
