#!/usr/bin/env nu

# Enrich a rustqual SARIF JSON file with derived `crate` and `category` fields.
#
# Replaces: enrich-sarif.nu (one-off in /tmp)
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/rust/enrich-sarif.nu *
#   enrich-sarif /tmp/rustqual-raw.sarif.json
#   enrich-sarif /tmp/rustqual-raw.sarif.json --out .ctx/findings.sarif.json
#   enrich-sarif /tmp/rustqual-raw.sarif.json --filter-category complexity
#   enrich-sarif /tmp/rustqual-raw.sarif.json --filter-crate api
#   open raw.sarif.json | enrich-sarif        # pipeline input
#
# Category mapping (ruleId → category):
#   iosp / VIOLATION           → "iosp"
#   CX-* / complexity          → "complexity"
#   DRY-* / DEAD_CODE / BP-*   → "dry"
#   SRP-* / SRP_*              → "srp"
#   TQ-* / TQ_*                → "test_quality"
#   CP-*                       → "coupling"
#   (other)                    → "other"
#
# Crate mapping (URI):
#   crates/<name>/...          → <name>
#   standalone/...             → "standalone"
#   services/<name>/...        → <name>
#   (other)                    → "root"

# Derive crate name from a SARIF artifact URI.
export def derive-crate [uri: string] {
    if ($uri | str contains "standalone/") {
        "standalone"
    } else if ($uri | str contains "crates/") {
        $uri | split row "/" | get 1
    } else if ($uri | str contains "services/") {
        $uri | split row "/" | get 1
    } else {
        "root"
    }
}

# Map a rustqual ruleId to a category string.
export def derive-category [rule_id: string] {
    if ("iosp" in $rule_id) or ($rule_id == "VIOLATION") {
        "iosp"
    } else if ($rule_id | str starts-with "CX-") or ("complexity" in $rule_id) {
        "complexity"
    } else if (($rule_id | str starts-with "DRY-") or ("DEAD_CODE" in $rule_id) or ("DUPLICATE" in $rule_id) or ("BOILERPLATE" in $rule_id) or ($rule_id | str starts-with "BP-")) {
        "dry"
    } else if ($rule_id | str starts-with "SRP-") or ($rule_id | str starts-with "SRP_") {
        "srp"
    } else if ($rule_id | str starts-with "TQ-") or ($rule_id | str starts-with "TQ_") {
        "test_quality"
    } else if ($rule_id | str starts-with "CP-") {
        "coupling"
    } else {
        "other"
    }
}

# Group enriched SARIF results by a field ("category" or "crate").
# Pipe the results list from an enriched SARIF record into this command.
# Each result must have a .properties record with the named field.
# Returns a record keyed by the group value, each value a list of results.
#
# Example:
#   enrich-sarif raw.sarif.json | get runs.0.results | sarif-group-by category
export def sarif-group-by [field: string] {
    group-by {|r| $r.properties | get $field }
}

export def enrich-sarif [
    input?: string           # Path to raw SARIF JSON (omit to read from pipeline)
    --out: string = ""       # Write enriched SARIF to this path (default: print to stdout)
    --filter-category: string = ""  # Keep only results matching this category
    --filter-crate: string = ""     # Keep only results matching this crate
] {
    let sarif = if ($input | is-empty) {
        $in
    } else {
        open $input
    }

    let enriched_results = (
        $sarif.runs.0.results | each {|result|
            let uri     = $result.locations.0.physicalLocation.artifactLocation.uri
            let rule_id = $result.ruleId
            let crate_v    = (derive-crate $uri)
            let category_v = (derive-category $rule_id)
            $result | insert properties {crate: $crate_v, category: $category_v}
        }
        | if ($filter_category | is-not-empty) {
            where {|r| $r.properties.category == $filter_category}
          } else { $in }
        | if ($filter_crate | is-not-empty) {
            where {|r| $r.properties.crate == $filter_crate}
          } else { $in }
    )

    let output = ($sarif | update runs [
        {
            tool:    $sarif.runs.0.tool,
            results: $enriched_results,
        }
    ])

    if ($out | is-not-empty) {
        $output | to json --indent 2 | save --force $out
        let count = ($enriched_results | length)
        print $"Enriched SARIF written to: ($out) — ($count) results"
    } else {
        $output
    }
}
