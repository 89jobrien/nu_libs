# bw — official Bitwarden CLI wrappers
#
# Companion to rbw.nu, which wraps the unofficial `rbw` client. Use this module
# when you want the official `bw` CLI: it speaks to any Bitwarden server, exposes
# custom fields, and is what notstrap/notsecrets shell out to.
#
# Every command needs an unlocked vault. Run `bw-unlock` once per shell — it
# stores the session token in `$env.BW_SESSION`, which the `bw` CLI and
# notsecrets both read.

# Return the current session token, or error with the fix.
def session [] {
    let s = $env.BW_SESSION? | default ''
    if ($s | is-empty) {
        error make {
            msg: 'bitwarden vault is locked'
            help: 'run `bw-unlock` first (or set $env.BW_SESSION)'
        }
    }
    $s
}

# Vault status as a record: status, serverUrl, userEmail, lastSync.
export def bw-status [] {
    ^bw status | from json
}

# True when the vault is unlocked and usable.
export def bw-unlocked [] {
    (bw-status | get status?) == 'unlocked'
}

# Unlock the vault and store the session token in $env.BW_SESSION.
#
# Logs in first if the account is unauthenticated. The password is read by `bw`
# itself, so it never passes through Nu's history or the process list.
export def --env bw-unlock [] {
    let st = bw-status
    if $st.status? == 'unauthenticated' {
        error make {
            msg: 'not logged in to bitwarden'
            help: 'run `bw login` first'
        }
    }
    $env.BW_SESSION = (^bw unlock --raw | str trim)
    print $"(ansi green)vault unlocked(ansi reset) — ($st.userEmail? | default 'unknown user')"
}

# Lock the vault and drop the cached session token.
export def --env bw-lock [] {
    ^bw lock
    hide-env -i BW_SESSION
}

# Sync the local vault cache with the server.
export def bw-sync [] {
    ^bw sync --session (session)
}

# All vault items as a table: name, username, id, folder.
export def bw-list [
    search?: string  # optional substring filter on item names
] {
    mut args = ['list' 'items' '--session' (session)]
    if ($search | is-not-empty) { $args ++= ['--search' $search] }
    ^bw ...$args
    | from json
    | each {|it|
        {
            name: $it.name
            username: ($it.login?.username? | default '')
            id: $it.id
            folder: ($it.folderId? | default '')
        }
    }
}

def cmpl-item [] {
    bw-list | each {|x| { value: $x.name, description: $x.username } }
}

# `bw get <object>` sub-commands that return a single value directly.
const NATIVE_FIELDS = ['password' 'username' 'uri' 'totp' 'notes' 'exposed']

def cmpl-field [] {
    $NATIVE_FIELDS
}

# Read one field of a vault item.
#
# Built-in field names go through `bw get <field> <item>`. Any other name is
# read from the item's custom fields, matched case-insensitively — the same
# rule notsecrets applies to `{ source = "bitwarden", field = "..." }`.
export def bw-get [
    item: string@cmpl-item   # item name or id
    field: string@cmpl-field = 'password'
] {
    let s = session
    if $field in $NATIVE_FIELDS {
        return (^bw get $field $item --session $s --nointeraction | str trim)
    }

    let fields = ^bw get item $item --session $s --nointeraction
    | from json
    | get fields?
    | default []
    let found = $fields
    | where {|f| ($f.name? | default '' | str downcase) == ($field | str downcase) }
    if ($found | is-empty) {
        error make {
            msg: $"item '($item)' has no field '($field)'"
            help: $"available fields: ($fields | get name? | str join ', ')"
        }
    }
    $found | first | get value
}

# Full item record, including custom fields.
export def bw-item [item: string@cmpl-item] {
    ^bw get item $item --session (session) --nointeraction | from json
}

# Current TOTP code for an item.
export def bw-code [item: string@cmpl-item] {
    ^bw get totp $item --session (session) --nointeraction | str trim
}

# Get password and TOTP code together — the bw counterpart of `rbws`.
export def bws [item: string@cmpl-item] {
    {
        password: (bw-get $item 'password')
        totp: (bw-code $item)
    }
}
