# [nu_lib] Send a desktop notification tagged with the current directory.
export def notify-self [msg?] {
    notify-send $env.pwd ($msg | default '')
}
