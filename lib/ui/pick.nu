# Fuzzy-select from piped input via the external `pick` tool.
#
# `pick` reads plain newline-delimited choices. Piping a Nushell table
# straight into it (`ls | pick`) stringifies every column into each line,
# which is unusable as a choice list. This flattens the input down to the
# "name" column (or the first column, for tables without one), then resolves
# the picked value back to its full original row. Plain lists of strings are
# passed through unchanged. All args are forwarded verbatim to `pick` itself
# (-d, -q, -S, etc.) — `--wrapped` keeps them from being parsed as this
# command's own flags.
export def --wrapped main [...args: string] {
    let input = $in
    let cols = ($input | columns)

    if ($cols | is-empty) {
        # Not a table/record list — treat as a plain list of strings.
        let choice = ($input | each { into string } | str join "\n" | ^pick ...$args)
        if ($choice | is-empty) { return null }
        $choice
    } else {
        let col = if "name" in $cols { "name" } else { $cols | first }
        let choice = ($input | get $col | each { into string } | str join "\n" | ^pick ...$args)
        if ($choice | is-empty) { return null }
        $input | where { |row| ($row | get $col | into string) == $choice } | first
    }
}
