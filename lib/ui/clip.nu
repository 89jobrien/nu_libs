# [nu_lib] Watch the Wayland clipboard, running `act` on every new copy and printing a separator between runs.
export def watch-clip [act] {
    wl-paste -w cat | each { $in | do $act; print $"\n(ansi grey)------(ansi reset)\n" }
}
