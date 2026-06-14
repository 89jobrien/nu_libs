# carapace.nu — Generate carapace completion specs from loaded Nu commands
#
# Carapace spec format: https://carapace-sh.github.io/carapace-bin/spec.html
# Specs are installed to ~/.config/carapace/specs/<command>.yaml
#
# Usage:
#   use lib/std/carapace.nu *
#   nul-carapace --filter "magi-"           # preview spec YAML
#   nul-carapace --filter "magi-" --install # write to ~/.config/carapace/specs/

def carapace-specs-dir [] {
    $env.HOME | path join ".config" "carapace" "specs"
}

# Map Nu param type to a carapace completion action string (empty = freeform)
def nu-type-to-carapace-action [t: string] {
    match $t {
        "path"  => "$files"
        "glob"  => "$files"
        _       => ""
    }
}

# Build a carapace spec record for a single Nu command
def cmd-to-spec [cmd: record] {
    let params = $cmd.params | flatten
    let switches = $params | where type == "switch"
    let named   = $params | where {|p| $p.name | str starts-with "-"} | where type != "switch"
    let positional = $params | where {|p| not ($p.name | str starts-with "-")} | where type != "switch"

    # flags: {--flag(-s): "description"}
    let flags = (
        $switches
        | each {|p|
            let clean = $p.name | str replace -r '\(.*\)' ''
            let desc  = $p.description? | default ""
            {$clean: $desc}
        }
        | append (
            $named | each {|p|
                let clean = $p.name | str replace -r '\(.*\)' ''
                let desc  = $p.description? | default ""
                {$"($clean)=": $desc}
            }
        )
        | reduce -f {} {|x, acc| $acc | merge $x}
    )

    # completion.positional: list of lists of values per position
    let pos_completions = (
        $positional | each {|p|
            let action = nu-type-to-carapace-action ($p.type? | default "string")
            if ($action | is-not-empty) { [$action] } else { [] }
        }
    )

    let completion = if ($pos_completions | flatten | is-not-empty) {
        {positional: $pos_completions}
    } else { {} }

    let spec = {
        name: $cmd.name
        description: ($cmd.description? | default "")
    }

    let spec = if ($flags | is-not-empty) { $spec | insert flags $flags } else { $spec }
    let spec = if ($completion | is-not-empty) { $spec | insert completion $completion } else { $spec }

    $spec
}

# Generate carapace spec YAML for loaded custom commands; optionally install to ~/.config/carapace/specs/
export def nul-carapace [
    --filter(-f): string = ""   # filter command names by substring
    --install(-i)               # write spec files to ~/.config/carapace/specs/
    --dry-run                   # show what would be written without writing
] {
    let cmds = (
        help commands
        | where command_type == "custom"
        | if ($filter | is-not-empty) { where name =~ $filter } else { $in }
    )

    let specs = $cmds | each {|cmd| cmd-to-spec $cmd}

    if $install {
        let specs_dir = carapace-specs-dir
        mkdir $specs_dir
        $specs | each {|spec|
            let filename = $spec.name | str replace --all " " "-"
            let dest = $specs_dir | path join $"($filename).yaml"
            if $dry_run {
                print $"[dry-run] would write ($dest)"
            } else {
                $spec | to yaml | save -f $dest
                print $"wrote ($dest)"
            }
        }
        null
    } else {
        $specs | to yaml
    }
}
