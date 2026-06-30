#!/usr/bin/env nu

# Insert a comment line into Rust source files at locations from a JSON file.
#
# Replaces one-off scripts: insert-todos.nu, add-no-assert.nu,
# add-suppressions.nu, fix_rustqual_todos.nu
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/rust/annotate.nu *
#   annotate-rust-lines --locations findings.json --comment "// TODO(rustqual/complexity): ..."
#   annotate-rust-lines --locations findings.json --comment "// qual:allow(...)" --anchor before-test-attr
#   annotate-rust-lines --locations findings.json --comment "// note" --anchor after-doc-block --dry-run
#
# Locations JSON shape: [{file: string, linenum: int}]
# linenum is 1-indexed.
#
# Anchor modes:
#   "at"               — insert immediately before the target line (default)
#   "before-test-attr" — scan backward from target for #[test]/#[tokio::test], insert before that
#   "after-doc-block"  — scan forward past leading //! lines, insert after the block
#                        (falls back to target line if no //! block found)

# Find insertion index for "at" mode.
# _lines is unused but kept for uniform signature across anchor helpers.
def _anchor_at [_lines: list<string>, idx: int] {
    $idx
}

# Find insertion index for "before-test-attr" mode.
# Scans backward up to 8 lines from idx for a #[test...] attribute.
# Returns the attribute line index, or $idx if not found.
def _anchor_before_test_attr [lines: list<string>, idx: int] {
    mut i = ($idx - 1)
    let limit = if ($i - 8) > 0 { $i - 8 } else { 0 }
    mut found = $idx
    while $i >= $limit {
        let trimmed = ($lines | get $i | str trim)
        if ($trimmed | str starts-with "#[test") or ($trimmed | str starts-with "#[tokio::test") {
            $found = $i
            break
        }
        $i = ($i - 1)
    }
    $found
}

# Find insertion index for "after-doc-block" mode.
# Scans forward from line 0 past consecutive //! lines.
# Falls back to $idx (the target line) if no //! block is present.
def _anchor_after_doc_block [lines: list<string>, idx: int] {
    mut doc_end = -1
    mut i = 0
    let total = ($lines | length)
    while $i < $total {
        let line = ($lines | get $i)
        if ($line | str starts-with "//!") {
            $doc_end = ($i + 1)
        } else if ($line | str trim | is-empty) and $doc_end >= 0 {
            break
        } else {
            break
        }
        $i = ($i + 1)
    }
    # If no //! block found, fall back to target line
    if $doc_end < 0 { $idx } else { $doc_end }
}

export def annotate-rust-lines [
    --locations: string          # Path to JSON file with [{file, linenum}] entries
    --comment: string            # Comment string to insert (indentation auto-detected from target line)
    --anchor: string = "at"      # "at" | "before-test-attr" | "after-doc-block"
    --base-dir: string = ""      # Optional root to prepend to relative file paths
    --dry-run                    # Print actions without modifying files
] {
    if ($locations | is-empty) { error make {msg: "--locations is required"} }
    if ($comment | is-empty)   { error make {msg: "--comment is required"} }
    if not ($locations | path exists) { error make {msg: $"locations file not found: ($locations)"} }

    let locs = (open $locations | each {|r| {file: $r.file, linenum: ($r.linenum | into int)} })
    let by_file = ($locs | group-by file)

    mut inserted = 0
    mut skipped  = 0

    for entry in ($by_file | transpose key value) {
        let rel  = $entry.key
        let path = if $base_dir != "" { $base_dir | path join $rel } else { $rel }

        if not ($path | path exists) {
            print $"  skip (file not found): ($path)"
            $skipped = ($skipped + ($entry.value | length))
            continue
        }

        # Sort descending so earlier insertions don't shift line numbers for later ones
        let line_nums = ($entry.value | get linenum | sort --reverse)
        mut lines = (open --raw $path | split row (char newline))

        for linenum in $line_nums {
            let idx = ($linenum - 1)  # convert to 0-indexed

            let anchor_idx = match $anchor {
                "before-test-attr" => (_anchor_before_test_attr $lines $idx),
                "after-doc-block"  => (_anchor_after_doc_block  $lines $idx),
                _                  => (_anchor_at $lines $idx),
            }

            # Idempotency: skip if line immediately before insertion already contains
            # the comment verbatim (after stripping indentation)
            let check_idx = ($anchor_idx - 1)
            if $check_idx >= 0 {
                let prev_trimmed = ($lines | get $check_idx | str trim)
                let comment_trimmed = ($comment | str trim)
                if $prev_trimmed == $comment_trimmed {
                    $skipped = ($skipped + 1)
                    continue
                }
            }

            # Detect indentation from the target line
            let target_line = ($lines | get $idx)
            let indent = (
                $target_line
                | split chars
                | take while {|c| $c == " " or $c == "\t"}
                | str join ""
            )
            let full_comment = $"($indent)($comment)"

            if $dry_run {
                let display_line = ($anchor_idx + 1)
                print $"  would insert @ ($path):($display_line): ($full_comment)"
                $inserted = ($inserted + 1)
                continue
            }

            let before = ($lines | first $anchor_idx)
            let after  = ($lines | skip $anchor_idx)
            $lines = ($before | append [$full_comment] | append $after)
            $inserted = ($inserted + 1)
        }

        if not $dry_run {
            $lines | str join (char newline) | save --force $path
        }
    }

    let action = if $dry_run { "would insert" } else { "inserted" }
    print $"Done: ($action) ($inserted), skipped ($skipped)"
}
