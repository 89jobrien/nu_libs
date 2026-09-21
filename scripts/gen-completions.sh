#!/usr/bin/env bash
# Regenerate Nushell completion modules into ~/dev/nu_libs/completions.
# Exposed globally as: mise run nu:completions
set -euo pipefail

OUT="$HOME/dev/nu_libs/completions"
mkdir -p "$OUT"

TOOLS="taskit agentlint aimem-cli braid-cli cnbl cargo-promote checkup-cli checkup-secx coursers devloop doob godmode-cli handb hooklings kan-cli kgx-cli maid mcpipe minibox-hooks mbx mlrs-cli notstrap nothooks notgraph nu-ai-daemon numcp propkit-cli repro rslm-cli rx-install toolz ail"

missing=""
failed=""

strip_help_items() {
    awk '
		BEGIN { pending = ""; dropping = 0 }
		dropping {
			if ($0 ~ /^[[:space:]]*\][[:space:]]*$/) {
				dropping = 0
			}
			next
		}
		/^[[:space:]]*(#.*)?$/ {
			pending = pending $0 ORS
			next
		}
		/^[[:space:]]*export extern "[^"]* help( |")/ {
			pending = ""
			dropping = 1
			next
		}
		{
			printf "%s", pending
			pending = ""
			print
		}
		END { printf "%s", pending }
	'
}

capture_completions() {
    local out="$1"
    shift
    local raw="$out.raw.tmp"
    local tmp="$out.tmp"

    if "$@" >"$raw" 2>/dev/null && [ -s "$raw" ]; then
        strip_help_items <"$raw" >"$tmp"
        rm -f "$raw"
        if [ -s "$tmp" ]; then
            mv "$tmp" "$out"
            return 0
        fi
    fi

    rm -f "$raw" "$tmp"
    return 1
}

try_generate() {
    local tool="$1"
    local out="$2"

    if capture_completions "$out" "$tool" completions; then
        return 0
    fi
    if capture_completions "$out" "$tool" completion nushell; then
        return 0
    fi
    if capture_completions "$out" "$tool" completions nushell; then
        return 0
    fi
    if capture_completions "$out" "$tool" --generate nushell; then
        return 0
    fi
    if capture_completions "$out" "$tool" generate-completions nushell; then
        return 0
    fi

    return 1
}

generate_with_mcpipe() {
    local tool="$1"
    local out="$2"
    local generated="$out.mcpipe.tmp"
    local list_tmp="$out.list.tmp"

    if ! command -v mcpipe >/dev/null 2>&1; then
        return 1
    fi
    if ! mcpipe --cli "$tool" --list >"$list_tmp" 2>/dev/null; then
        rm -f "$list_tmp"
        return 1
    fi

    local cmds
    cmds="$(awk 'NF>0 {print $1}' "$list_tmp" | sort -u)"
    if [ -z "$cmds" ]; then
        rm -f "$list_tmp"
        return 1
    fi

    {
        printf 'module completions {\n\n'
        printf '  export extern %s [\n' "$tool"
        printf '    --help(-h)                # Print help\n'
        printf '  ]\n\n'
        for cmd in $cmds; do
            printf '  export extern "%s %s" [\n' "$tool" "$cmd"
            printf '    --help(-h)                # Print help\n'
            printf '  ]\n\n'
        done
        printf '}\n\n'
        printf 'export use completions *\n'
    } >"$generated"

    rm -f "$list_tmp"
    if capture_completions "$out" cat "$generated"; then
        rm -f "$generated"
        return 0
    fi

    rm -f "$generated"
    return 1
}

main() {
    for tool in $TOOLS; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing="$missing $tool"
            continue
        fi

        if try_generate "$tool" "$OUT/$tool.nu"; then
            printf 'ok: %s\n' "$tool"
        elif generate_with_mcpipe "$tool" "$OUT/$tool.nu"; then
            printf 'ok-mcpipe: %s\n' "$tool"
        else
            failed="$failed $tool"
        fi
    done

    if [ -n "$missing" ]; then
        printf 'missing:%s\n' "$missing" >&2
    fi

    if [ -n "$failed" ]; then
        printf 'failed:%s\n' "$failed" >&2
    fi

    echo "done: completions refreshed in $OUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
