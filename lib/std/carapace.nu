# carapace.nu — Generate carapace completion specs from loaded Nu commands
#
# Carapace spec format: https://carapace-sh.github.io/carapace-bin/spec.html
# Specs are installed to Carapace's platform/XDG config directory.
#
# Usage:
#   use lib/std/carapace.nu *
#   nul-carapace --filter "magi-"           # preview spec YAML
#   nul-carapace --filter "magi-" --install # write to the Carapace specs directory
#   sync-carapace-specs                     # install tracked completion specs

const CARAPACE_MODULE_PATH = (path self)

def platform-config-home [] {
    if $nu.os-info.name == "macos" {
        $env.HOME | path join "Library" "Application Support"
    } else if $nu.os-info.name == "windows" {
        $env.APPDATA? | default ($env.HOME | path join "AppData" "Roaming")
    } else {
        $env.HOME | path join ".config"
    }
}

def carapace-specs-dir [] {
    let xdg_config_home = $env.XDG_CONFIG_HOME? | default ""
    let expanded_xdg = if ($xdg_config_home | is-empty) {
        ""
    } else {
        $xdg_config_home | path expand --no-symlink
    }

    if ($xdg_config_home | is-not-empty) and $xdg_config_home == $expanded_xdg {
        $xdg_config_home | path join "carapace" "specs"
    } else {
        platform-config-home | path join "carapace" "specs"
    }
}

def nu-libs-root [] {
    $CARAPACE_MODULE_PATH | path dirname | path dirname | path dirname
}

def tracked-carapace-specs [] {
    let repo_root = nu-libs-root
    glob ($repo_root | path join "completions" "carapace" "*.yaml")
    | sort
}

def atomic-copy [source: path, destination: path] {
    let destination_dir = $destination | path dirname
    let temporary = (
        $destination_dir
        | path join $".($destination | path basename).(random uuid).tmp"
    )

    try {
        cp $source $temporary
        mv --force $temporary $destination
    } catch {|err|
        if ($temporary | path exists) {
            rm $temporary
        }
        error make {msg: $"failed to install ($source): ($err.msg)"}
    }
}

# [nu_lib] Install tracked Carapace YAML specs with atomic per-file replacement.
export def sync-carapace-specs [
    --dry-run # report copies without changing the specs directory
] {
    let specs_dir = carapace-specs-dir
    let specs = tracked-carapace-specs

    if ($specs | is-empty) {
        error make {msg: $"no tracked Carapace specs found under (nu-libs-root)"}
    }

    if not $dry_run {
        mkdir $specs_dir
    }

    $specs | each {|source|
        let destination = $specs_dir | path join ($source | path basename)

        if $dry_run {
            {
                spec: ($source | path basename)
                destination: $destination
                status: "would-copy"
            }
        } else {
            atomic-copy $source $destination
            {
                spec: ($source | path basename)
                destination: $destination
                status: "copied"
            }
        }
    }
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

# [nu_lib] Generate carapace spec YAML for loaded custom commands; optionally install it.
export def nul-carapace [
    --filter(-f): string = ""   # filter command names by substring
    --install(-i)               # write spec files to the Carapace specs directory
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
        if not $dry_run {
            mkdir $specs_dir
        }
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
