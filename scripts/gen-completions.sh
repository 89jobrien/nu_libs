#!/usr/bin/env bash
# Regenerate Nushell completion modules into ~/dev/nu_libs/completions.
# Exposed globally as: mise run nu:completions
set -euo pipefail

OUT="$HOME/dev/nu_libs/completions"
mkdir -p "$OUT"

TOOLS="taskit agentlint aimem braid-cli cnbl cargo-promote checkup secx coursers devloop doob godmode handb hooklings kan-cli kgx maid mcpipe minibox-hooks mbx mlrs notstrap nothooks notgraph nu-ai-daemon numcp propkit repro rslm rx toolz ail"

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

# Emit one module line per option found in a clap-style `Options:` block.
# Handles all four clap renderings: `-s, --long <VAL>`, `--long <VAL>`,
# `--long`, and short-only. Long and short never both take a value in clap.
extract_option_flags() {
    awk '
        function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
        function strip_value(s) {
            if (match(s, /^[[:space:]]*<[^>]*>/))      return substr(s, RLENGTH + 1)
            if (match(s, /^[[:space:]]*\[[^]]*\]/))    return substr(s, RLENGTH + 1)
            if (match(s, /^[[:space:]]*=[^[:space:]]*/)) return substr(s, RLENGTH + 1)
            return s
        }
        function describe(s,   d, cut) {
            sub(/[[:space:]]*\[default:[^]]*\][[:space:]]*$/, "", s)
            d = trim(s)
            gsub(/"/, "", d)
            if (d == "") return ""
            if (length(d) > 96) {
                d = substr(d, 1, 96)
                if (match(d, /^.*[[:space:]]/)) d = substr(d, 1, RLENGTH - 1) "..."
            }
            return d
        }
        /^Options:[[:space:]]*$/ { in_sect = 1; next }
        in_sect && /^[^[:space:]]/ { exit }
        !in_sect { next }
        {
            line = $0
            sub(/^[[:space:]]+/, "", line)

            if (match(line, /^-[a-zA-Z0-9], --[a-zA-Z0-9][a-zA-Z0-9_-]*/)) {
                short = substr(line, 2, 1)
                long  = substr(line, 7, RLENGTH - 6)
                rest  = substr(line, RLENGTH + 1)
            } else if (match(line, /^--[a-zA-Z0-9][a-zA-Z0-9_-]*/)) {
                short = ""
                long  = substr(line, 3, RLENGTH - 2)
                rest  = substr(line, RLENGTH + 1)
            } else if (match(line, /^-[a-zA-Z0-9]/)) {
                short = substr(line, 2, 1)
                long  = ""
                rest  = substr(line, RLENGTH + 1)
            } else {
                next
            }

            if (long == "help" || long == "version") next
            if (short == "h" || short == "V") next

            sub(/^\.\.\.[[:space:]]*/, "", rest)

            after = strip_value(rest)
            takes = (after != rest)

            if (long != "") {
                name = (short != "") ? "--" long "(-" short ")" : "--" long
            } else {
                name = "-" short
            }
            if (takes) name = name ": string"

            d = describe(after)
            if (d == "") print "    " name
            else print "    " sprintf("%-26s", name) "# " d
        }
    ' "$1"
}

# Emit one name per subcommand found in a clap-style `Commands:` block.
extract_subcommands() {
    awk '
        /^Commands:[[:space:]]*$/ { in_sect = 1; next }
        in_sect && /^[^[:space:]]/ { exit }
        in_sect && NF > 0 && $1 !~ /^(help|help-man|completion|completions)$/ { print $1 }
    ' "$1" | sort -u
}

# Last-resort generator for clap CLIs that ship no `completions` subcommand:
# read `<tool> --help` and synthesise an extern per subcommand, with the
# top-level option flags attached to the bare extern.
generate_from_help() {
    local tool="$1"
    local out="$2"
    local help="$out.help.tmp"
    local generated="$out.helpgen.tmp"

    case "$tool" in
    [a-zA-Z0-9_-]*) ;;
    *) return 1 ;;
    esac

    rm -f "$help"
    if ! "$tool" --help >"$help" 2>/dev/null; then
        if ! "$tool" -h >"$help" 2>/dev/null; then
            rm -f "$help"
            return 1
        fi
    fi
    if [ ! -s "$help" ]; then
        rm -f "$help"
        return 1
    fi

    local subcmds flags
    subcmds="$(extract_subcommands "$help")"
    flags="$(extract_option_flags "$help")"

    if [ -z "$subcmds" ] && [ -z "$flags" ]; then
        rm -f "$help"
        return 1
    fi

    {
        printf 'module completions {\n\n'
        printf '  export extern %s [\n' "$tool"
        printf '    --help(-h)                # Print help\n'
        if [ -n "$flags" ]; then
            printf '%s\n' "$flags"
        fi
        printf '  ]\n\n'
        for cmd in $subcmds; do
            printf '  export extern "%s %s" [\n' "$tool" "$cmd"
            printf '    --help(-h)                # Print help\n'
            printf '  ]\n\n'
        done
        printf '}\n\n'
        printf 'export use completions *\n'
    } >"$generated"

    rm -f "$help"
    if capture_completions "$out" cat "$generated"; then
        rm -f "$generated"
        return 0
    fi

    rm -f "$generated"
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
        elif generate_from_help "$tool" "$OUT/$tool.nu"; then
            printf 'ok-help: %s\n' "$tool"
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
