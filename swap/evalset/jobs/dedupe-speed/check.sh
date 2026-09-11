#!/usr/bin/env bash
# check.sh <workdir> — Chapter 10. Exits 0 only if the job is done.
#   1 = too slow, wrong order, or the new test is missing
#   2 = the test suite failed
#   3 = the work directory is missing
#
# Two seconds, not one. The job asks for under a second and a correct answer
# lands near 0.05s, so the gap is enormous either way — but a loaded CI box can
# make a correct solution look slow, and a flaky evaluator is worse than a slow
# one. See GOTCHAS.md.
set -uo pipefail
cd "${1:?usage: check.sh <workdir>}" || exit 3

[[ -f tests/test_dedupe_order.py ]] || exit 1

python3 - <<'PY' || exit 1
import sys, time
sys.path.insert(0, ".")
from dedupe import dedupe

rows = [line.rstrip("\n") for line in open("rows.txt", encoding="utf-8")]
start = time.perf_counter()
got = dedupe(rows)
elapsed = time.perf_counter() - start

seen, want = set(), []
for r in rows:
    if r not in seen:
        seen.add(r)
        want.append(r)

assert got == want, "dedupe no longer returns first-seen order"
assert elapsed < 2.0, f"dedupe took {elapsed:.2f}s"
PY

out=$(python3 -m unittest discover -s tests -p "test_*.py" 2>&1) || exit 2
[[ "$out" == *"Ran 0 tests"* ]] && exit 1
exit 0
