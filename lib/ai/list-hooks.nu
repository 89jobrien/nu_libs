#!/usr/bin/env nu

# Discover all agent harness hooks reachable from a root directory.
#
# Reads three hook sources:
#   .claude/settings.json      — Claude Code global and project-level hooks
#   .codex/hooks.json          — Codex project-level hooks (same shape)
#   ~/.config/crs/plugins.d/   — crs hook plugin TOML definitions
#
# Usage:
#   use /Users/joe/dev/nu_libs/lib/ai/list-hooks.nu
#   list-hooks                      # search from ~
#   list-hooks --root .             # search from cwd
#   list-hooks --event PreToolUse   # filter by event
#   list-hooks --source crs         # filter by source type: settings|codex|crs
#   list-hooks --json               # raw JSON

# Parse hooks from a .claude/settings.json or .codex/hooks.json file.
# Both share the same shape:
#   { "hooks": { "EventName": [ { "matcher": "...", "hooks": [{ "command": "..." }] } ] } }
def _parse_hook_settings [file: string] {
    if not ($file | path exists) { return [] }
    let data = try { open $file } catch { return [] }
    if not ("hooks" in ($data | columns)) { return [] }
    let hooks_map = $data.hooks
    $hooks_map | columns | each {|event|
        let entries = ($hooks_map | get $event)
        if ($entries | is-empty) { return [] }
        $entries | each {|entry|
            let matcher = if ("matcher" in ($entry | columns)) { $entry.matcher } else { "*" }
            if not ("hooks" in ($entry | columns)) { return [] }
            $entry.hooks | each {|h|
                {
                    source:  $file
                    event:   $event
                    matcher: $matcher
                    label:   ($h.command | split row " " | first | path basename)
                    action:  "run"
                    command: $h.command
                }
            }
        } | flatten
    } | flatten
}

# Normalize kebab-case crs event names to PascalCase (matches settings.json convention).
# "pre-tool-use" → "PreToolUse"
def _kebab_to_pascal [s: string] {
    $s | split row "-" | each { str capitalize } | str join
}

# Parse hooks from a crs plugin TOML file (plugins.d/*.toml).
# Shape: [[hooks]] label=... event=... matcher=... action=... pattern/command/message=...
def _parse_crs_toml [file: string] {
    if not ($file | path exists) { return [] }
    let data = try { open $file } catch { return [] }
    if not ("hooks" in ($data | columns)) { return [] }
    $data.hooks | each {|h|
        # command field may be a list<string> or absent (deny/rewrite use pattern instead)
        let cmd = if ("command" in ($h | columns)) {
            let c = $h.command
            if ($c | describe) =~ "list" { $c | str join " " } else { $c }
        } else if ("pattern" in ($h | columns)) {
            $h.pattern
        } else { "" }
        {
            source:  $file
            event:   (_kebab_to_pascal $h.event)
            matcher: (if ("matcher" in ($h | columns)) { $h.matcher } else { "*" })
            label:   (if ("label" in ($h | columns)) { $h.label } else { "" })
            action:  $h.action
            command: $cmd
        }
    }
}

# Discover all agent harness hooks reachable from a root directory.
export def main [
    --root: string = ""     # Directory to search from (default: ~)
    --event: string = ""    # Filter to this event (e.g. PreToolUse, Stop)
    --source: string = ""   # Filter by source type: settings | codex | crs
    --json                  # Output JSON instead of table
] {
    let search_root = if ($root | is-not-empty) { $root } else { $env.HOME }

    # Find all candidate JSON hook files under root
    let json_files = (
        do {
            ^fd --type f --hidden --exclude ".cargo" --exclude "target" --exclude "node_modules" --exclude ".git" "(settings|hooks)\\.json$" $search_root
        } | complete | get stdout | lines
        | where { str length | $in > 0 }
        | where {|f|
            ($f | str ends-with "/.claude/settings.json")
            or ($f | str ends-with ".codex/hooks.json")
        }
    )

    # Always include the crs plugin directory (not under HOME search typically)
    let crs_dir = ($env.HOME | path join ".config" "crs" "plugins.d")
    let crs_files = if ($crs_dir | path exists) {
        glob $"($crs_dir)/*.toml"
    } else { [] }

    let settings_files = ($json_files | where { str ends-with "/.claude/settings.json" })
    let codex_files    = ($json_files | where { str ends-with ".codex/hooks.json" })

    let from_settings = ($settings_files | each {|f| _parse_hook_settings $f } | flatten)
    let from_codex    = ($codex_files    | each {|f| _parse_hook_settings $f } | flatten)
    let from_crs      = ($crs_files      | each {|f| _parse_crs_toml $f      } | flatten)

    let all = (
        $from_settings | append $from_codex | append $from_crs
        | if ($event | is-not-empty) {
            where { $in.event == $event }
          } else { $in }
        | if ($source | is-not-empty) {
            where {|r|
                if $source == "settings" { $r.source | str ends-with "settings.json" }
                else if $source == "codex" { $r.source | str ends-with "hooks.json" }
                else if $source == "crs"   { $r.source | str ends-with ".toml" }
                else { true }
            }
          } else { $in }
        | sort-by event matcher source
    )

    if $json {
        return ($all | to json)
    }

    # Shorten source paths for readability
    let home = $env.HOME
    $all | each {|r|
        $r | update source ($r.source | str replace $"($home)/" "~/")
    } | select source event matcher label action command
}
