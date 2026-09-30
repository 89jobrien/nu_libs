#!/usr/bin/env bash
# Assert every completions/*.nu corresponds to a TOOLS entry and vice versa.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

TOOLS_RAW="$(grep '^TOOLS=' scripts/gen-completions.sh | cut -d= -f2 | tr -d '"')"
# shellcheck disable=SC2086
tr ' ' '\n' <<<"$TOOLS_RAW" | grep -v '^$' | sort >/tmp/tools.txt

find completions -maxdepth 1 -name '*.nu' -exec basename {} .nu \; | sort >/tmp/mods.txt

echo "TOOLS entries: $(wc -l </tmp/tools.txt | tr -d ' ')"
echo "modules:       $(wc -l </tmp/mods.txt | tr -d ' ')"

if diff -u /tmp/tools.txt /tmp/mods.txt; then
    echo "MATCH: every tool has a module and every module has a tool"
else
    echo "MISMATCH: lines above are modules-only (>) or tools-only (<)"
    exit 1
fi
