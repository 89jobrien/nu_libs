# [nu_lib] Serialize a value to a JSON string with quotes escaped, for embedding inline.
export def 'json-to-string' [json] {
    $json | to json -r | str replace --all '"' '\"'
}

# [nu_lib] Open piped-in text in $env.EDITOR via a temp file, stashing --context in $env.AI_EDITOR_CONTEXT for ai-editor-run to pick up later.
export def block-edit [
    temp
    --context: record
] {
    let content = $in
    let d = mktemp -d -t $temp
    let tf = [$d ai.md] | path join
    $content | save -f $tf
    if ($context | is-not-empty) {
        $env.AI_EDITOR_CONTEXT = $context | upsert file $tf | to nuon
    }
    cd $d
    ^$env.EDITOR $tf
    let c = open $tf --raw
    rm -f $tf
    $c
}

# [nu_lib] Substitute {{var}} placeholders in a piped-in template string with values from `vars`.
export def render [vars: record] {
    let tmpl = $in
    let v = $tmpl
    | parse -r '(?<!{){{(?<v>[^{}]*?)}}(?!})'
    | get v
    | uniq

    $v
    | reduce -f $tmpl {|i, a|
        let k = $i | str trim
        let k = if ($k | is-empty) { '_' } else { $k }
        $a | str replace --all $"{{($i)}}" ($vars | get $k | to text)
    }
}

# [nu_lib] Best-effort deserialize a piped-in string as YAML, then JSON, then NUON; pass non-strings through unchanged.
export def try_json [] {
    let i = $in
    if ($i | describe) == 'string' {
        mut x = ''
        $x = do -i { $i | from yaml }
        if ($x | is-not-empty) { return $x }
        $x = do -i { $i | from json }
        if ($x | is-not-empty) { return $x }
        $x = do -i { $i | from nuon }
        if ($x | is-not-empty) { return $x }
        return 'Deserialization failed'
    } else {
        $i
    }
}
