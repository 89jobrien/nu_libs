# Fuzzy-select from piped input via the external `pick` tool.
#
# `pick` reads plain newline-delimited choices. Piping a Nushell table
# straight into it (`ls | pick`) stringifies every column into each line,
# which is unusable as a choice list. This flattens tabular input down to
# the "name" column (or the first column, for tables without one), then
# resolves the picked value back to its full original row. Plain strings
# (e.g. `cat file | pick`) and lists of strings (e.g. `grep ... | pick`)
# are forwarded to `pick` as-is. All args are forwarded verbatim to `pick`
# itself (-d, -q, -S, etc.) — `--wrapped` keeps them from being parsed as
# this command's own flags.
export def --wrapped main [...args: string] {
    let input = $in
    let cols = (try { $input | columns } catch { [] })

    if ($cols | is-empty) {
        # Not tabular: a plain string, or a list of strings — either way,
        # `to text` already renders it as pick expects (a string is passed
        # through untouched; a list is newline-joined).
        let choice = ($input | to text | ^pick ...$args)
        if ($choice | is-empty) { return null }
        $choice
    } else {
        let col = if "name" in $cols { "name" } else { $cols | first }
        let choice = ($input | get $col | each { into string } | str join "\n" | ^pick ...$args)
        if ($choice | is-empty) { return null }
        $input | where { |row| ($row | get $col | into string) == $choice } | first
    }
}
