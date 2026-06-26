# gkg — Knowledge Graph helpers
# Wraps the gkg CLI and HTTP API (localhost:27495) for symbol search,
# codebase stats, and .kgx wiki population.
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/gkg/mod.nu *
#
# Requires: gkg server running (`gkg server start`)

const GKG_BASE = "http://localhost:27495"

# Encode an absolute path for use in gkg API URL segments.
# e.g. "/Users/joe/dev/maestro" → "%2FUsers%2Fjoe%2Fdev%2Fmaestro"
# TODO(review): Replace slash-only escaping with full URL encoding that also handles spaces,
# percent signs, query delimiters, and fragments without breaking gkg's path-segment API shape.
def gkg-encode-path [path: string]: nothing -> string {
    $path | str replace -ra "/" "%2F"
}

# Build the base URL segment for a gkg project endpoint.
# workspace and project are usually the same path for single-repo workspaces.
def gkg-url [endpoint: string, workspace: string, project: string]: nothing -> string {
    let w = gkg-encode-path $workspace
    let p = gkg-encode-path $project
    $"($GKG_BASE)/api/graph/($endpoint)/($w)/($p)"
}

# Index a repo (or workspace of repos) with gkg.
# Runs gkg index and reports completion.
export def "gkg index" [
    path: string = "."  # Path to index (default: current dir)
    --verbose (-v)      # Verbose output
    --threads (-t): int = 0  # Worker threads (0 = auto)
]: nothing -> nothing {
    let args = (
        ["index" $path "--threads" ($threads | into string)]
        | if $verbose { append "--verbose" } else { $in }
    )
    ^gkg ...$args
}

# Get stats for an indexed project.
# Returns a record with total_nodes, total_relationships, node_counts, etc.
export def "gkg stats" [
    project: string = "."  # Project path (default: cwd)
    --workspace (-w): string  # Workspace path (default: same as project)
]: nothing -> record {
    let proj = ($project | path expand)
    let ws = if ($workspace | is-empty) { $proj } else { $workspace | path expand }
    let url = gkg-url "stats" $ws $proj
    http get $url
}

# Search for symbols in an indexed project.
# Returns a table of matching nodes with file, line, fqn, and type.
export def "gkg search" [
    term: string           # Search term (symbol name, fqn fragment, etc.)
    --project (-p): string = "."  # Project path
    --workspace (-w): string      # Workspace path (default: same as project)
    --limit (-l): int = 50        # Max results
    --type (-t): string           # Filter by node type (DefinitionNode, FileNode, etc.)
]: nothing -> table {
    let proj = ($project | path expand)
    let ws = if ($workspace | is-empty) { $proj } else { $workspace | path expand }
    let url = $"(gkg-url "search" $ws $proj)?search_term=($term | url encode)&limit=($limit)"
    let raw = http get $url
    let nodes = $raw | get nodes
    let result = $nodes | each {|row|
        {
            type: $row.node_type
            label: $row.label
            id: $row.id
            path: ($row.properties | get -o path | default "")
            fqn: ($row.properties | get -o fqn | default "")
            line: ($row.properties | get -o start_line | default 0)
            def_type: ($row.properties | get -o definition_type | default "")
        }
    }
    if ($type | is-empty) {
        $result
    } else {
        # TODO(review): This filters after the server-side limit, so valid matches can be hidden.
        # Push type filtering into the gkg API when supported, or document this as sampled output.
        $result | where type == $type
    }
}

# Check whether gkg server is reachable and a project is indexed.
export def "gkg status" [
    project: string = "."
    --workspace (-w): string
]: nothing -> record {
    let proj = ($project | path expand)
    let ws = if ($workspace | is-empty) { $proj } else { $workspace | path expand }
    let url = gkg-url "stats" $ws $proj
    let data = try { http get $url } catch { null }
    if $data != null {
        {
            reachable: true
            status: ($data | get -o project_info.status | default "unknown")
            last_indexed: ($data | get -o project_info.last_indexed_at | default "")
            total_nodes: ($data.total_nodes)
            total_relationships: ($data.total_relationships)
        }
    } else {
        {
            reachable: false
            status: "unreachable"
            last_indexed: ""
            total_nodes: 0
            total_relationships: 0
        }
    }
}

# List all symbols of a given type in the graph (sampled via a broad search).
# Useful for discovering what's indexed.
export def "gkg list-defs" [
    --project (-p): string = "."
    --workspace (-w): string
    --limit (-l): int = 200
    --def-type (-d): string = ""  # e.g. Function, Method, Struct, Trait, Enum
]: nothing -> table {
    let proj = ($project | path expand)
    let ws = if ($workspace | is-empty) { $proj } else { $workspace | path expand }
    let url = $"(gkg-url "search" $ws $proj)?search_term=&limit=($limit)"
    let raw = http get $url
    let nodes = $raw | get nodes
    let defs = $nodes | where node_type == "DefinitionNode" | each {|row|
        {
            label: $row.label
            fqn: ($row.properties | get -o fqn | default "")
            path: ($row.properties | get -o path | default "")
            line: ($row.properties | get -o start_line | default 0)
            def_type: ($row.properties | get -o definition_type | default "")
        }
    }
    if ($def_type | is-empty) {
        $defs
    } else {
        $defs | where def_type == $def_type
    }
}
