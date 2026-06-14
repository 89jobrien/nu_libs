# openapi.nu — Generate an OpenAPI 3.1 schema from currently loaded Nu commands
#
# Usage:
#   use lib/std/openapi.nu *
#   nu-libschema                        # schema for all custom commands
#   nu-libschema --filter "magi-"       # filter by name prefix
#   nu-libschema --format yaml          # YAML output (default: json)

# Map Nu param types to OpenAPI property schema
def nu-type-to-schema [t: string] {
    match $t {
        "int"      => {type: "integer"}
        "float"    => {type: "number"}
        "bool"     => {type: "boolean"}
        "switch"   => {type: "boolean", default: false}
        "path"     => {type: "string", format: "path"}
        "duration" => {type: "string", format: "duration"}
        "datetime" => {type: "string", format: "date-time"}
        "list"     => {type: "array", items: {type: "string"}}
        "record"   => {type: "object"}
        _          => {type: "string"}
    }
}

# Build a flattened properties record from a param list, keyed by clean name
def params-to-properties [params: list] {
    $params
    | each {|p|
        # strip leading dashes and short-form from names like "--filter(-f)"
        let clean = $p.name | str replace -r '^-+' '' | str replace -r '\(.*\)' '' | str trim
        let schema = nu-type-to-schema ($p.type? | default "string")
        let desc   = $p.description? | default ""
        {
            key: $clean
            value: ($schema | merge (if ($desc | is-not-empty) { {description: $desc} } else { {} }))
        }
    }
    | reduce -f {} {|x, acc| $acc | insert $x.key $x.value}
}

# Build an OpenAPI operation object from a command help record
def cmd-to-operation [cmd: record] {
    let params     = $cmd.params | flatten
    let positional = $params | where {|p| $p.type != "switch" and not ($p.name | str starts-with "-")}
    let opts       = $params | where {|p| $p.name | str starts-with "-"}
    let required_fields = $positional | where required == true | each {|p| $p.name | str trim}

    let properties = params-to-properties ($positional | append $opts)

    {
        operationId: ($cmd.name | str replace --all " " "_")
        summary: ($cmd.description? | default "")
        requestBody: {
            required: (($required_fields | length) > 0)
            content: {
                "application/json": {
                    schema: {
                        type: "object"
                        required: $required_fields
                        properties: $properties
                    }
                }
            }
        }
        responses: {
            "200": {
                description: "Command output"
                content: {"application/json": {schema: {type: "object"}}}
            }
        }
    }
}

# Generate an OpenAPI 3.1 schema from all currently loaded custom commands
export def nu-libschema [
    --filter(-f): string = ""       # filter command names by substring
    --format: string = "json"       # output format: json or yaml
    --title: string = "nu_libs"     # schema title
    --version: string = "1.0.0"     # schema version
    --prefix: string = ""           # prepend a prefix to all operationIds and paths (e.g. "nu-")
] {
    let cmds = (
        help commands
        | where command_type == "custom"
        | if ($filter | is-not-empty) { where name =~ $filter } else { $in }
    )

    let paths = (
        $cmds
        | each {|cmd|
            let op   = cmd-to-operation $cmd
            let slug = $cmd.name | str replace --all ' ' '/'
            let path = $"/($prefix)($slug)"
            let op_prefixed = if ($prefix | is-not-empty) {
                $op | update operationId $"($prefix)($op.operationId)"
            } else { $op }
            {key: $path, value: {post: $op_prefixed}}
        }
        | reduce -f {} {|x, acc| $acc | insert $x.key $x.value}
    )

    let schema = {
        openapi: "3.1.0"
        info: {title: $title, version: $version}
        paths: $paths
    }

    match $format {
        "yaml" => { $schema | to yaml }
        _      => { $schema | to json --indent 2 }
    }
}
