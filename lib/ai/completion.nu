use sqlite.nu *
use base.nu
use data.nu

# [nu_lib] Completer: offer message indices (with content previews) from the current session's history.
export def cmpl-sessoin-offset [ctx] {
    let session = if NU_ARGX_EXISTS in $env {
        $ctx | argx parse | get -o opt.fork
    }
    let session = if ($session | is-empty) { $env.AI_SESSION } else { $session }
    let w = ((term size).columns / 2 | math floor) - 8
    let c = sqlx $"select substr\(content, 0, ($w)\) as description from messages where session_id = ($session)"
    | enumerate
    | each {|x| {value: ($x.index + 1), description: $x.item.description} }
    { completions: $c, options: { sort: false, partial: false } }
}

def cmpl-models-temp [path ctx] {
    let provider = if NU_ARGX_EXISTS in $env {
        let ctx = $ctx | argx parse
        $ctx | get -o $path
    }
    let s = data session -p $provider
    base ai-models $s
}

# [nu_lib] Completer: model names for the --provider named flag's value.
export def cmpl-models [ctx] {
    cmpl-models-temp ([opt provider] | into cell-path)  $ctx
}

# [nu_lib] Completer: model names for a positional provider argument.
export def cmpl-models-pos [ctx] {
    cmpl-models-temp ([pos provider] | into cell-path) $ctx
}

# [nu_lib] Completer: registered tool names from $env.AI_TOOLS.
export def cmpl-tools [] {
    $env.AI_TOOLS | columns
}

# [nu_lib] Completer: recent `ai-do` scratch entries, most recently updated first.
export def cmpl-previous [] {
    let rw = (term size).columns - 22
    sqlx $"select id as value,
            substr\(
                updated || '│' ||
                type || '|' ||
                printf\('%-20s', args\) || '│' ||
                model || '|' ||
                content,
                0, ($rw)
            \) as description
        from scratch order by updated desc limit 10;"
    | { completions: $in, options: { sort: false } }
}

# [nu_lib] Completer for ai-do's positional args: prompt name first, then that prompt's placeholder values in order.
export def 'cmpl-role' [ctx] {
    let args = $ctx | split row '|' | last | str trim -l | split row ' ' | slice 1..
    let len = $args | length
    match $len {
        1 => {
            cmpl-prompt
        }
        _ => {
            let d = sqlx $"select * from prompt where name = (Q $args.0)"
            let d = $d | first | get placeholder | from yaml
            let pos = $len - 2
            let n = $d | get $pos
            sqlx $"select yaml from placeholder where name = (Q $n)"
            | first | get yaml | from yaml | columns
        }
    }
}


def cmpl-config [context] {
    let ctx = $context | split row -r '\s+' | slice 1..
    if ($ctx | length) < 2 {
        return [provider, prompt, function]
    } else {
        sqlx $'select name from ($ctx.0)' | get name
    }
}

# [nu_lib] Completer: configured provider names, marking the current session's provider(s) and the active default.
export def cmpl-provider [] {
    let current = sqlx $"select provider from sessions where id = ($env.AI_SESSION)"
    | get provider
    sqlx $'select name, active from provider'
    | each {|x|
        let a = if $x.active > 0 {'*'} else {''}
        let c = if $x.name in $current {'+'} else {''}
        {value: $x.name, description: $"($c)($a)"}
    }
}

# [nu_lib] Completer: known prompt names, from $env.AI_PROMPTS plus the prompt table.
export def cmpl-prompt [] {
    $env.AI_PROMPTS
    | values
    | select name description
    | rename value
    | insert style {fg: xterm_blue}
    | append (sqlx "select name as value, description from prompt")
    | { completions: $in, options: { sort: false } }
}

# [nu_lib] Completer: prompt names that have a non-empty system message.
export def cmpl-system [] {
    sqlx $"select name from prompt where system != ''"
    | get name
}

# [nu_lib] Completer: 6 evenly-spaced temperature values within the current session's provider range.
export def cmpl-temperature [] {
    let s = data session
    let tr = ($s.temp_max - $s.temp_min) / 5
    0..5 | each { $in * $tr }
}
