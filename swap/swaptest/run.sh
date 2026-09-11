#!/usr/bin/env bash
# run.sh <alias> — Chapter 4, wired through Chapter 5's adapter.
# Run the fixed job once, on one alias, print four numbers.
# Every line of this exists to hold something still.
#
# This one calls a model, so it needs your own CLI and your own allowance.
set -uo pipefail
ALIAS="${1:?usage: run.sh <alias>}"
HERE="$(cd "$(dirname "$0")" && pwd)"
TIMEOUT=600
for t in timeout python3; do command -v "$t" >/dev/null || {
  echo "run.sh: $t is not on PATH." >&2
  [ "$t" = timeout ] && echo "  timeout is GNU coreutils: brew install coreutils." >&2
  exit 69; }
done

rm -rf "$HERE/work"
cp -R "$HERE/fixtures" "$HERE/work"

START=$(date +%s)
# The adapter resolves the alias and picks the CLI. Chapter 4 called one vendor
# here directly; Chapter 5 replaced that block with this line, which is why
# models.txt is the only file in the tree that names a vendor.
timeout "$TIMEOUT" "$HERE/../adapter/call.sh" \
    "$ALIAS" "$HERE/job.md" "$HERE/work" "$HERE/raw-$ALIAS.json" \
  || { echo "adapter failed for '$ALIAS' (exit $?) — nothing ran" >&2; exit 64; }
WALL=$(( $(date +%s) - START ))

# Do not drop the || above. Without it the adapter prints its error, this script
# carries on, sheet.py finds no output file, and the sheet reports "json contract
# wrong" — a confident diagnosis of a run that never happened.

"$HERE/check.sh" "$HERE/work" >/dev/null 2>&1
PASS=$?

python3 "$HERE/sheet.py" "$ALIAS" "$WALL" "$PASS" "$HERE/raw-$ALIAS.json"
