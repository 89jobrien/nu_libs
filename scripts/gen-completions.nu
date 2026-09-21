#!/usr/bin/env nu
# Regenerate Nushell completion modules into ~/dev/nu_libs/completions.
# Exposed globally as: mise run nu:completions

const tools = [
    taskit
    agentlint
    aimem-cli
    braid-cli
    cnbl
    cargo-promote
    checkup-cli
    checkup-secx
    coursers
    devloop
    doob
    godmode-cli
    handb
    hooklings
    kan-cli
    kgx-cli
    maid
    mcpipe
    minibox-hooks
    mbx
    mlrs-cli
    notstrap
    nothooks
    notgraph
    nu-ai-daemon
    numcp
    propkit-cli
    repro
    rslm-cli
    rx-install
    toolz
    ail
]

def strip-help-items [text: string] {
    let state = $text
        | lines
        | reduce --fold {output: [], pending: [], dropping: false} {|line, state|
            if $state.dropping {
                if ($line =~ '^\s*\]\s*$') {
                    $state | update dropping false
                } else {
                    $state
                }
            } else if ($line =~ '^\s*(#.*)?$') {
                $state | update pending ($state.pending | append $line)
            } else if ($line =~ '^\s*export extern "[^"]* help( |")') {
                $state | merge {pending: [], dropping: true}
            } else {
                let output = $state.output | append $state.pending | append $line
                $state | merge {output: $output, pending: []}
            }
        }

    let output = $state.output | append $state.pending
    (($output | str join (char newline)) + (char newline))
}

def write-completions [out: path, raw: string] {
    let filtered = strip-help-items $raw
    if ($filtered | str trim | is-empty) {
        return false
    }

    let tmp = $'($out).tmp'
    $filtered | save --force $tmp
    mv --force $tmp $out
    true
}

def capture-completions [out: path, tool: string, args: list<string>] {
    let result = do { run-external $tool ...$args } | complete
    if $result.exit_code != 0 or ($result.stdout | is-empty) {
        return false
    }

    write-completions $out $result.stdout
}

def try-generate [tool: string, out: path] {
    let invocations = [
        [completions]
        [completion nushell]
        [completions nushell]
        [--generate nushell]
        [generate-completions nushell]
    ]

    for args in $invocations {
        if (capture-completions $out $tool $args) {
            return true
        }
    }

    false
}

def generate-with-mcpipe [tool: string, out: path] {
    if (which mcpipe | is-empty) {
        return false
    }

    let result = do { mcpipe --cli $tool --list } | complete
    if $result.exit_code != 0 {
        return false
    }

    let commands = $result.stdout
        | lines
        | where {|line| $line | str trim | is-not-empty}
        | each {|line| $line | str trim | split row -r '\s+' | first}
        | uniq
        | sort

    if ($commands | is-empty) {
        return false
    }

    mut lines = [
        'module completions {'
        ''
        $'  export extern ($tool) ['
        '    --help(-h)                # Print help'
        '  ]'
    ]
    for command in $commands {
        $lines ++= [
            ''
            $'  export extern "($tool) ($command)" ['
            '    --help(-h)                # Print help'
            '  ]'
        ]
    }
    $lines ++= ['' '}' '' 'export use completions *']

    let generated = (($lines | str join (char newline)) + (char newline))
    write-completions $out $generated
}

export def main [] {
    let out = $env.HOME | path join dev nu_libs completions
    mkdir $out

    mut missing = []
    mut failed = []

    for tool in $tools {
        if (which $tool | is-empty) {
            $missing = $missing | append $tool
        } else if (try-generate $tool ($out | path join $'($tool).nu')) {
            print $'ok: ($tool)'
        } else if (generate-with-mcpipe $tool ($out | path join $'($tool).nu')) {
            print $'ok-mcpipe: ($tool)'
        } else {
            $failed = $failed | append $tool
        }
    }

    if ($missing | is-not-empty) {
        print --stderr $'missing: ($missing | str join " ")'
    }
    if ($failed | is-not-empty) {
        print --stderr $'failed: ($failed | str join " ")'
    }

    print $'done: completions refreshed in ($out)'
}
