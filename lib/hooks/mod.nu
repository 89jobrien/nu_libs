# hooks — Claude Code hook I/O primitives
#
# Usage in hook scripts:
#   use /Users/joe/dev/nu_libs/lib/hooks *
#
#   def main [] {
#       let input = hook-stdin
#       if $input == null { exit 0 }
#       ...
#       hook-allow
#   }

# Read and parse the Claude hook payload from stdin.
# Returns null on parse failure (hook should exit 0 gracefully).
export def hook-stdin [] {
    try { open --raw /dev/stdin | from json } catch { null }
}

# Emit an allow decision to stdout.
export def hook-allow [] {
    {decision: "allow"} | to json | print
}

# Emit a block/deny decision with a reason to stdout.
export def hook-deny [reason: string] {
    {decision: "block", reason: $reason} | to json | print
}

# Emit a non-blocking system message to stdout.
export def hook-system-message [msg: string] {
    {systemMessage: $msg} | to json | print
}

# Extract a field from hook input with a default.
# Equivalent to: $input | get --optional $field | default $fallback
export def hook-field [input: record, field: string, fallback: string = ""] {
    $input | get --optional $field | default $fallback
}
