#!/usr/bin/env bash
# run-all.sh <alias> — Chapter 10. Run every job in the set once on one alias.
# Prints one tab-separated row per job: alias, job, pass|fail, cost, seconds.
#
#   ./run-all.sh fast > results.tsv && ./run-all.sh deep >> results.tsv
#   python3 report.py results.tsv
#
# This one calls a model, so it needs your own CLI and subscription.
set -uo pipefail
ALIAS="${1:?usage: run-all.sh <alias>}"
HERE="$(cd "$(dirname "$0")" && pwd)"
ADAPTER="$HERE/../adapter/call.sh"

for JOB in "$HERE"/jobs/*/; do
  NAME=$(basename "$JOB")
  WORK=$(mktemp -d)
  cp -R "$JOB/fixtures/." "$WORK/"
  RAW="$WORK/.raw.json"

  START=$(date +%s)
  "$ADAPTER" "$ALIAS" "$JOB/job.md" "$WORK" "$RAW" >/dev/null \
    || { echo "adapter failed for '$ALIAS' (exit $?) — nothing ran" >&2; exit 64; }
  WALL=$(( $(date +%s) - START ))

  "$JOB/check.sh" "$WORK" >/dev/null 2>&1
  PASS=$?

  COST=$(python3 -c "
import json
try: print(f\"{json.load(open('$RAW')).get('total_cost_usd',0.0):.4f}\")
except Exception: print('0.0000')")

  printf '%s\t%s\t%s\t%s\t%s\n' "$ALIAS" "$NAME" \
    "$([ $PASS -eq 0 ] && echo pass || echo fail)" "$COST" "$WALL"
  rm -rf "$WORK"
done
