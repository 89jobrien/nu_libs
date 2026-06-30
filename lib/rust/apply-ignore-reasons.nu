#!/usr/bin/env nu

# Upgrade bare #[ignore] attributes to #[ignore = "reason"] using a TOML rule registry.
#
# Replaces: apply-ignore-reasons.nu (one-off in /tmp, giant if/else hardcoded to maestro)
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/rust/apply-ignore-reasons.nu *
#   apply-ignore-reasons --rules .config/ignore-reasons.toml
#   apply-ignore-reasons --rules .config/ignore-reasons.toml --dry-run
#   list-unmatched-ignores --rules .config/ignore-reasons.toml
#
# Rule registry TOML shape (.config/ignore-reasons.toml):
#   [[rules]]
#   pattern = "maestro-runtime/src/middleware/**/e2e.rs"
#   reason = "Requires Docker: {stem} middleware E2E test"
#
#   [[rules]]
#   pattern = "aops-e2e/tests/k8s_integration*"
#   reason = "Requires K3d cluster -- runs only on CI"
#
# Pattern matching: glob syntax. {stem} in reason is replaced with the file stem.
# Supported metacharacters: * (single segment), ** (multi-segment), . (literal).
# Other regex metacharacters in patterns (parens, brackets, +) are escaped.
# Files with no matching rule are reported but not modified.

# Convert a glob pattern to a regex string.
# Escapes all regex metacharacters except * before expanding wildcards.
def _glob_to_regex [pattern: string] {
    $pattern
    # Escape regex metacharacters (except * which we handle separately)
    | str replace --all '(' '\('
    | str replace --all ')' '\)'
    | str replace --all '[' '\['
    | str replace --all ']' '\]'
    | str replace --all '+' '\+'
    | str replace --all '?' '\?'
    | str replace --all '^' '\^'
    | str replace --all '$' '\$'
    | str replace --all '{' '\{'
    | str replace --all '}' '\}'
    | str replace --all '.' '\.'
    # Expand wildcards (order matters: ** before *)
    | str replace --all '**/' '(.+/)?'
    | str replace --all '**' '.*'
    | str replace --all '*' '[^/]*'
}

# Match a relative file path against a glob pattern.
def _glob_match [path: string, pattern: string] {
    let regex = (_glob_to_regex $pattern)
    ($path | str replace -r $"^($regex)$" "__match__") == "__match__"
}

# Look up the first matching rule for a relative file path.
# Returns null (empty) if no rule matches.
def _find_rule [rules: list<record>, rel_path: string] {
    let matches = ($rules | where {|r| _glob_match $rel_path $r.pattern })
    if ($matches | length) == 0 { null } else { $matches | first }
}

# Substitute {stem} in a reason string with the file's stem (basename without extension).
def _apply_stem [reason: string, path: string] {
    let stem = ($path | path basename | path parse | get stem)
    $reason | str replace --all "{stem}" $stem
}

# Find all Rust files containing bare #[ignore] and return their paths.
def _candidate_files [root: string] {
    do { ^rg -l '#\[ignore\]' --type rust $root } | complete
    | get stdout
    | lines
    | where {|f| ($f | str length) > 0 }
}

export def apply-ignore-reasons [
    --rules: string       # Path to TOML rule registry (required)
    --root: string = "."  # Workspace root to search for Rust files
    --dry-run             # Print changes without writing files
] {
    if ($rules | is-empty) { error make {msg: "--rules is required"} }
    if not ($rules | path exists) { error make {msg: $"rules file not found: ($rules)"} }

    let rule_list = (open $rules | get rules)
    let candidates = (_candidate_files $root)

    mut modified  = 0
    mut total_ann = 0
    mut unmatched = []

    for file in $candidates {
        let rel = ($file | str replace $"($root)/" "")
        let matched_rule = (_find_rule $rule_list $rel)

        if ($matched_rule == null) {
            $unmatched = ($unmatched | append $rel)
            continue
        }

        let reason = (_apply_stem $matched_rule.reason $file)
        let content = (open --raw $file)

        # Skip if no bare #[ignore] remains (already fully annotated)
        if not ($content | str contains "#[ignore]") { continue }

        let count = ($content | split row "#[ignore]" | length) - 1
        let new_content = ($content | str replace --all "#[ignore]" $'#[ignore = "($reason)"]')

        if $dry_run {
            print $"  would update ($rel): ($count) → \"($reason)\""
        } else {
            $new_content | save --force $file
            print $"  updated ($rel): ($count)"
        }

        $modified  = ($modified + 1)
        $total_ann = ($total_ann + $count)
    }

    let action = if $dry_run { "would update" } else { "updated" }
    print $"\nDone: ($action) ($total_ann) annotation(s) in ($modified) file(s)"

    if ($unmatched | length) > 0 {
        let u = ($unmatched | length)
        print $"\n($u) file(s) with #[ignore] but no matching rule — run `list-unmatched-ignores` for details"
    }
}

# Show all #[ignore] occurrences in files that have no matching rule in the registry.
# Useful for auditing gaps in the rule set before running apply-ignore-reasons.
export def list-unmatched-ignores [
    --rules: string       # Path to TOML rule registry (required)
    --root: string = "."  # Workspace root
] {
    if ($rules | is-empty) { error make {msg: "--rules is required"} }
    if not ($rules | path exists) { error make {msg: $"rules file not found: ($rules)"} }

    let rule_list = (open $rules | get rules)
    let candidates = (_candidate_files $root)

    let unmatched = (
        $candidates | where {|file|
            let rel = ($file | str replace $"($root)/" "")
            (_find_rule $rule_list $rel) == null
        }
    )

    if ($unmatched | length) == 0 {
        print "All #[ignore] files have matching rules."
        return
    }

    let count = ($unmatched | length)
    print $"($count) file(s) with no matching rule:"
    for file in $unmatched {
        let rel = ($file | str replace $"($root)/" "")
        let hits = (do { ^rg -n '#\[ignore\]' $file } | complete | get stdout | lines | where {|l| ($l | str length) > 0 })
        print $"  ($rel)"
        $hits | each {|l| print $"    ($l)"}
    }
}
