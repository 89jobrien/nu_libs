def "nu-complete ps" [] {
    ps -l | each {|x| { value: $"($x.pid)", description: $x.command } }
}

# [nu_lib] after <pid> {|| do something ... }
export def main [
    pid: string@"nu-complete ps"
    action
] {
    do -i { tail --pid $pid -f /dev/null }
    do $action
}

# [nu_lib] before {|| do something ... } <pid>
export def before [
    action
    pid: string@"nu-complete ps"
] {
    do -i { tail --pid $pid -f /dev/null }
    do $action
}
