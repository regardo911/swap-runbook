#!/usr/bin/env bash
# check.sh — Chapter 4. Deterministic evaluator. Exit 0 = the job is done.
#   1 = the --json contract is wrong   2 = the test suite failed
#   3 = the work directory is missing
# Takes a directory. With no argument it uses work/, which is what run.sh made.
set -uo pipefail
cd "${1:-$(dirname "$0")/work}" || exit 3

python3 - <<'PY' || exit 1
import json, subprocess, sys
r = subprocess.run([sys.executable, "linecount.py", "--json", "sample.txt"],
                   capture_output=True, text=True)
assert r.returncode == 0, f"exit {r.returncode}: {r.stderr[:200]}"
d = json.loads(r.stdout)
assert set(d) == {"file", "lines"}, f"keys were {sorted(d)}"
assert isinstance(d["lines"], int) and d["lines"] == 3, f"lines={d['lines']!r}"
PY

python3 -m unittest discover -s tests -p "test_*.py" >/dev/null 2>&1 || exit 2
exit 0
