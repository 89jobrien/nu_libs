#!/usr/bin/env bash
# Assert the three things that must agree about completion modules:
#   1. gen-completions.sh TOOLS  <->  completions/*.nu
#   2. every completions/*.nu    ->  is referenced by the autoload list
#   3. every autoload reference   ->  points at a file that exists
#
# (2) and (3) close a cross-repo link: the autoload list is owned by
# notfiles, not by this repo, so renaming a module here silently breaks
# every new shell. Nushell resolves `use` paths at parse time, so one
# missing module aborts the whole autoload before anything is evaluated.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

AUTOLOAD="${NU_LIBS_AUTOLOAD:-$HOME/.notfiles/nushell/.config/nushell/autoload/nu_libs.nu}"

# Fixed temp names: the previous version used shared /tmp paths, so two
# concurrent runs could read each other's files.
TOOLS_TMP="$(mktemp)"
MODS_TMP="$(mktemp)"
AUTO_TMP="$(mktemp)"
trap 'rm -f "$TOOLS_TMP" "$MODS_TMP" "$AUTO_TMP"' EXIT

status=0

# --- 1. TOOLS <-> modules -------------------------------------------------
TOOLS_RAW="$(grep '^TOOLS=' scripts/gen-completions.sh | cut -d= -f2 | tr -d '"')"
# shellcheck disable=SC2086
tr ' ' '\n' <<<"$TOOLS_RAW" | grep -v '^$' | sort >"$TOOLS_TMP"

find completions -maxdepth 1 -name '*.nu' -exec basename {} .nu \; | sort >"$MODS_TMP"

echo "TOOLS entries: $(wc -l <"$TOOLS_TMP" | tr -d ' ')"
echo "modules:       $(wc -l <"$MODS_TMP" | tr -d ' ')"

if diff -u "$TOOLS_TMP" "$MODS_TMP"; then
    echo "MATCH: every tool has a module and every module has a tool"
else
    echo "MISMATCH: lines above are modules-only (>) or tools-only (<)"
    status=1
fi

# --- 2/3. autoload list <-> modules ---------------------------------------
# The autoload list lives in the notfiles repo. Skip rather than fail when
# it is absent, so this stays runnable on a machine that has not linked it.
if [[ ! -f "$AUTOLOAD" ]]; then
    echo "SKIP: autoload list not found at $AUTOLOAD"
    echo "      (set NU_LIBS_AUTOLOAD to override; nu_libs autoload link is not present)"
    exit "$status"
fi

echo ""
echo "autoload list:  $AUTOLOAD"

# Module basenames the autoload file names in a const path.
grep -o '/completions/[A-Za-z0-9_-]*\.nu' "$AUTOLOAD" \
    | sed 's#.*/##; s#\.nu$##' | sort -u >"$AUTO_TMP"

referenced="$(wc -l <"$AUTO_TMP" | tr -d ' ')"
echo "referenced:     $referenced"

# Every referenced path must exist on disk, or `use` aborts the autoload.
missing=0
while IFS= read -r line; do
    path="$(printf '%s\n' "$line" | sed 's/^const [^=]*= *//; s/^"//; s/"$//')"
    [[ -z "$path" ]] && continue
    if [[ ! -f "$path" ]]; then
        printf 'MISSING: %s\n' "$path"
        missing=$((missing + 1))
    fi
done < <(grep -o '/[^"]*completions/[A-Za-z0-9_-]*\.nu' "$AUTOLOAD" | sort -u)

if ((missing > 0)); then
    echo "BROKEN: $missing autoload reference(s) point at files that do not exist."
    echo "        Nushell resolves use at parse time, so this breaks every new shell."
    status=1
else
    echo "OK: every autoload reference exists"
fi

# Every module on disk should be loaded, or its completions are dead weight.
unref=""
while IFS= read -r mod; do
    if ! grep -qx "$mod" "$AUTO_TMP"; then
        unref="$unref $mod"
    fi
done <"$MODS_TMP"

if [[ -n "$unref" ]]; then
    # shellcheck disable=SC2086
    echo "UNLOADED: modules not referenced by the autoload list:$unref"
    status=1
else
    echo "OK: every module is referenced by the autoload list"
fi

exit "$status"
