#!/usr/bin/env bash
# Assert every completions/carapace/<x>.yaml declares `name: x`, and that each
# spec is loadable enough to have a description.
#
# The carapace specs are hand-maintained -- gen-completions.sh does not
# generate them and nothing has been regenerating or checking them. That is
# the same gap that let the .nu modules drift: f31ee74 had to rename nine
# modules (aimem-cli.nu -> aimem.nu, rx-install.nu -> rx.nu, and so on)
# because the file names and the commands they completed had parted ways,
# which broke every new shell with nu::parser::module_not_found.
#
# The carapace equivalent of that failure is a spec file named one thing whose
# `name:` completes another. This asserts the two agree, so the same class of
# bug cannot land silently.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

spec_dir="completions/carapace"
status=0

if [ ! -d "$spec_dir" ]; then
    echo "MISSING: $spec_dir does not exist"
    exit 1
fi

tmp_files="$(mktemp)"
tmp_names="$(mktemp)"
trap 'rm -f "$tmp_files" "$tmp_names"' EXIT

# filename stem -> declared spec name
for f in "$spec_dir"/*.yaml; do
    [ -e "$f" ] || continue
    stem="$(basename "$f" .yaml)"
    name="$(grep -m1 '^name:' "$f" | sed 's/^name:[[:space:]]*//; s/[[:space:]]*$//')"

    if [ -z "$name" ]; then
        echo "NO-NAME: $stem.yaml has no top-level 'name:'"
        status=1
        continue
    fi

    if ! grep -q '^description:' "$f"; then
        echo "NO-DESC: $stem.yaml has no 'description:' (renders blank in the shell menu)"
        status=1
    fi

    echo "$stem" >>"$tmp_files"
    echo "$name" >>"$tmp_names"
done

sort -o "$tmp_files" "$tmp_files"
sort -o "$tmp_names" "$tmp_names"

echo "spec files: $(wc -l <"$tmp_files" | tr -d ' ')"
echo "spec names: $(wc -l <"$tmp_names" | tr -d ' ')"

if diff -u "$tmp_files" "$tmp_names"; then
    echo "MATCH: every spec file name matches the command it completes"
else
    echo "MISMATCH: lines above are spec-name-only (>) or file-name-only (<)."
    echo "         A spec completing a different command than its file name is"
    echo "         the same silent-drift bug that broke the .nu modules."
    status=1
fi

# Informational only. A spec for a tool that is not installed is normal -- the
# spec ships ahead of the binary, or the tool lives outside this PATH.
missing=""
while read -r n; do
    [ -n "$n" ] || continue
    command -v "$n" >/dev/null 2>&1 || missing="$missing $n"
done <"$tmp_names"

if [ -n "$missing" ]; then
    echo ""
    echo "not on PATH (informational, not a failure):$missing"
fi

exit $status
