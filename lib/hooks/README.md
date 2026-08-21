# lib/hooks

I/O primitives for Claude Code hook scripts. One file, `mod.nu` — everything is
defined directly in it rather than re-exported.

```nu
use lib/hooks *
```

## Commands

| Command                        | Does                                                  |
| ------------------------------ | ----------------------------------------------------- |
| `hook-stdin`                   | Read and parse the hook payload from stdin. **Returns `null` on parse failure** |
| `hook-allow`                   | Emit `{decision: "allow"}`                            |
| `hook-deny <reason>`           | Emit `{decision: "block", reason: ...}`               |
| `hook-system-message <msg>`    | Emit `{systemMessage: ...}` — non-blocking            |
| `hook-field <input> <field> [fallback]` | Read a field from the payload with a default |

`hook-field` is shorthand for `$input | get --optional $field | default $fallback`.

## The shape of a hook script

```nu
use /path/to/nu_libs/lib/hooks *

def main [] {
    let input = hook-stdin
    if $input == null { exit 0 }
    # ... inspect $input ...
    hook-allow
}
```

`hook-stdin` swallows parse errors and hands back `null` on purpose: a hook that
crashes on malformed input blocks the tool call it was inspecting. Always check
for `null` and `exit 0` — failing open is the intended behavior.

## Related

`lib/git/git-hooks.nu` installs and manages git hooks; this category is about
what a hook script does once it's running.
