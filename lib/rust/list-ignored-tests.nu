#!/usr/bin/env nu

# List all #[ignore]d tests in a Rust workspace with file, line, crate, and function name.
# Requires `rg` (ripgrep) on PATH.
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/rust/list-ignored-tests.nu *
#   list-ignored-tests                      # table output
#   list-ignored-tests --root /path/to/ws   # explicit root
#   list-ignored-tests --by-crate           # grouped markdown report
#   list-ignored-tests --json               # raw JSON

export def list-ignored-tests [
    --root: string = "."  # Workspace root to search from
    --by-crate            # Print a grouped markdown report instead of a table
    --json                # Output raw JSON
] {
    let raw = (do { ^rg -n '#\[ignore' --type rust $root } | complete)
    if $raw.exit_code != 0 {
        if $json { return "[]" }
        print "(no ignored tests found)"
        return []
    }

    # Parse file:linenum pairs from rg output
    let ignores = (
        $raw.stdout
        | lines
        | where {|l| ($l | str length) > 0 }
        | each {|l|
            let parts = ($l | split row ":")
            {file: ($parts | get 0), line: ($parts | get 1 | into int)}
        }
    )

    # For each #[ignore] location, scan forward up to 5 lines for the fn name
    let results = (
        $ignores | each {|ig|
            let file_lines = (open --raw $ig.file | lines)
            let total = ($file_lines | length)
            # skip() is 0-indexed; ig.line is 1-indexed so ig.line points past the #[ignore] line
            let search_start = $ig.line
            if $search_start >= $total { return null }
            let take_n = if ($total - $search_start) < 5 { $total - $search_start } else { 5 }
            let search = ($file_lines | skip $search_start | first $take_n)
            let fn_line = ($search | where {|l| $l =~ 'fn '} | first)
            if ($fn_line != null) {
                let name = (
                    $fn_line
                    | str trim
                    | str replace 'async ' ''
                    | str replace 'pub(crate) ' ''
                    | str replace 'pub ' ''
                    | str replace 'fn ' ''
                    | str replace -r '\(.*' ''
                )
                # Derive crate from first path segment relative to root
                let rel = ($ig.file | str replace $"($root)/" "")
                let crate_name = ($rel | split row "/" | get 0)
                {crate: $crate_name, file: $ig.file, line: $ig.line, test: $name}
            }
        }
        | compact
        | uniq-by {|r| $"($r.file):($r.test)"}
        | sort-by crate file line
    )

    if $json {
        return ($results | to json)
    }

    if $by_crate {
        let by_crate = ($results | group-by crate)
        for crate_name in ($by_crate | columns | sort) {
            let tests = ($by_crate | get $crate_name)
            let count = ($tests | length)
            print $"## ($crate_name) \(($count)\)"
            print ""
            for t in $tests {
                print $"- `($t.test)` — ($t.file):($t.line)"
            }
            print ""
        }
        let total = ($results | length)
        print $"**Total: ($total) ignored tests**"
        return
    }

    $results
}
