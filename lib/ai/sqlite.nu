# [nu_lib] Quote/escape a value (or joined values) for safe inline use in a SQL string.
export def Q [...t --sep:string=''] {
    let s = $t | str join $sep | str replace -a "'" "''"
    $"'($s)'"
}

# [nu_lib] Run a SQL statement against $env.AI_STATE.
export def sqlx [s] {
    open $env.AI_STATE | query db $s
}

# [nu_lib] Create a SQLite database at `file` (running `hook` to set up schema) if it doesn't exist, and point $env.<env_name> at it.
export def --env init-db [env_name:string, file:string, hook: closure] {
    let begin = date now
    if $env_name not-in $env {
        {$env_name: $file} | load-env
    }
    if ($file | path exists) { return }
    mkdir ($file | path parse | get parent)
    {_: '.'} | into sqlite -t _ $file
    open $file | query db "DROP TABLE _;"
    do $hook {|s| open $file | query db $s } {|...t| Q ...$t }
    print $"(ansi grey)created database: $env.($env_name), takes ((date now) - $begin)(ansi reset)"
}

# [nu_lib] INSERT a record into `table` with ON CONFLICT upsert (or DO NOTHING) keyed on `pk`.
export def db-upsert [table pk --do-nothing] {
    let r = $in
    let d = if $do_nothing { 'NOTHING' } else {
        let u = $r | columns | each {|x| $"($x) = EXCLUDED.($x)" } | str join ', '
        $"UPDATE SET ($u)"
    }
    sqlx $"
        INSERT INTO ($table)\(($r | columns | str join ',')\)
        VALUES\(($r | values | each {Q $in} | str join ',')\)
        ON CONFLICT\(($pk | str join ', ')\) DO ($d);"
}

# [nu_lib] Merge piped-in fields onto a config's defaults, run an optional transform action, and select only the default's columns.
export def table-merge [
    config
    --action: closure
] {
    let d = $in
    let d = $config.default | merge $d
    let d = if ($action | is-not-empty) {
        $d | do $action $config
    } else {
        $d
    }
    $d | select ...($config.default | columns)
}

# [nu_lib] Insert/update (or --delete) a config-table row, built via table-merge, keyed on config.pk.
export def table-upsert [
    config
    --delete
    --action: closure
] {
    let r = $in
    | table-merge $config --action $action
    if $delete {
        let pks = $config.default
        | columns
        | reduce -f {} {|i,a|
            if $i in $config.pk {
                $a | insert $i ($r | get $i)
            } else {
                $a
            }
        }
        | items {|k,v|
            $"($k) = (Q $v)"
        }
        | str join ' and '
        sqlx $"delete from ($config.table) where ($pks)"
    } else {
        $r | db-upsert $config.table $config.pk
    }
}

# [nu_lib] Insert (prompt, tool) pairs into prompt_tools from a piped-in record of {prompt: [tools]}.
export def insert-prompt-tools [] {
    $in
    | transpose k v
    | each {|x|
        let v = $x.v | each { $"\((Q $x.k), (Q $in)\)" } | str join ', '
        sqlx $"insert or replace into prompt_tools \(prompt, tool\) values ($v);"
    }
}
