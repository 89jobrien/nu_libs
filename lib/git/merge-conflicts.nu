#!/usr/bin/env nu

# Report git merge conflicts categorized by type.
#
# Replaces one-off scripts: conflict-check.nu, extract-conflicts.nu, categorize.nu
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/git/merge-conflicts.nu *
#   merge-conflicts                        # preview merge with origin/main
#   merge-conflicts --against feat/foo     # preview merge with a specific ref
#   merge-conflicts --json                 # output structured data

# Categorize a list of raw CONFLICT lines by conflict type.
# Returns a record: {content, add_add, rename_delete, modify_delete, other}
# each value is a list of the raw conflict strings.
export def categorize-conflicts [
    lines: list<string>
] {
    mut content        = []
    mut add_add        = []
    mut rename_delete  = []
    mut modify_delete  = []
    mut other          = []

    for line in $lines {
        if ($line | str contains "(content)") or ($line | str contains "both modified") {
            $content = ($content | append $line)
        } else if ($line | str contains "(add/add)") or ($line | str contains "both added") {
            $add_add = ($add_add | append $line)
        } else if ($line | str contains "(rename/delete)") {
            $rename_delete = ($rename_delete | append $line)
        } else if ($line | str contains "(modify/delete)") {
            $modify_delete = ($modify_delete | append $line)
        } else {
            $other = ($other | append $line)
        }
    }

    {
        content:       $content,
        add_add:       $add_add,
        rename_delete: $rename_delete,
        modify_delete: $modify_delete,
        other:         $other,
    }
}

export def merge-conflicts [
    --against: string = "origin/main"  # Ref to preview merge against
    --json                             # Output JSON instead of human summary
    --repo: string = "."               # Git repo root (uses git -C)
] {
    let result = (do { ^git -C $repo merge-tree --write-tree HEAD $against } | complete)

    # merge-tree writes conflict info to stderr, conflicting file list to stdout
    let conflict_lines = (
        $result.stderr
        | lines
        | where {|l| ($l | str starts-with "CONFLICT") and (not ($l | str contains "file location")) }
    )

    let conflicting_files = (
        $result.stdout
        | lines
        | where {|l| ($l | str length) > 0 and ($l | str starts-with "1")}
        | each {|l| $l | split row "\t" | last }
        | uniq
    )

    let categories = (categorize-conflicts $conflict_lines)

    let summary = {
        total_conflicts: ($conflict_lines | length),
        conflicting_files: ($conflicting_files | length),
        by_type: {
            content:       ($categories.content | length),
            add_add:       ($categories.add_add | length),
            rename_delete: ($categories.rename_delete | length),
            modify_delete: ($categories.modify_delete | length),
            other:         ($categories.other | length),
        },
        files: $conflicting_files,
        raw: $categories,
    }

    if $json {
        $summary | to json
        return
    }

    print $"Conflicting files: ($summary.conflicting_files)"
    print $"Total CONFLICT lines: ($summary.total_conflicts)"
    print ""

    if ($categories.content | length) > 0 {
        print $"=== content (($categories.content | length)) ==="
        $categories.content | each {|l| print $"  ($l)"}
        print ""
    }
    if ($categories.add_add | length) > 0 {
        print $"=== add/add (($categories.add_add | length)) ==="
        $categories.add_add | each {|l| print $"  ($l)"}
        print ""
    }
    if ($categories.rename_delete | length) > 0 {
        print $"=== rename/delete (($categories.rename_delete | length)) ==="
        $categories.rename_delete | each {|l| print $"  ($l)"}
        print ""
    }
    if ($categories.modify_delete | length) > 0 {
        print $"=== modify/delete (($categories.modify_delete | length)) ==="
        $categories.modify_delete | each {|l| print $"  ($l)"}
        print ""
    }
    if ($categories.other | length) > 0 {
        print $"=== other (($categories.other | length)) ==="
        $categories.other | each {|l| print $"  ($l)"}
    }

    if ($summary.conflicting_files) > 0 {
        print ""
        print "=== files ==="
        $conflicting_files | each {|f| print $"  ($f)"}
    }
}
