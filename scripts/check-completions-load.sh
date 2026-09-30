#!/usr/bin/env bash
# Load every generated completion module in a clean nu session and report
# failures. Complements gen-completions.sh, which only checks exit status.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
status=0

for f in completions/*.nu; do
    name="$(basename "$f" .nu)"
    if out="$(nu --no-config-file -c "use $f *; 'ok'" 2>&1)"; then
        printf 'ok   %s\n' "$name"
    else
        status=1
        printf 'FAIL %s\n%s\n' "$name" "$out"
    fi
done

exit $status
