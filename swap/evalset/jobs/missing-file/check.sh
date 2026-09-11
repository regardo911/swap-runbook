#!/usr/bin/env bash
# check.sh <workdir> — Chapter 10. Exits 0 only if the job is done.
#   1 = the behaviour is wrong or the artifact is missing
#   2 = the test suite failed
#   3 = the work directory is missing
#
# The two extra assertions matter more than the suite does. ch10 prints a short
# wrapper that runs unittest and nothing else, and that wrapper exits 0 on these
# untouched fixtures: at the starting state the new test does not exist yet, so
# discover collects only passing tests and returns 0. A checker that passes
# before the work is done reports every model as perfect forever. So: assert the
# behaviour, assert the artifact exists, and assert the suite collected
# something. See GOTCHAS.md.
set -uo pipefail
cd "${1:?usage: check.sh <workdir>}" || exit 3

err=$(python3 linecount.py no_such_file.txt 2>&1 >/dev/null); rc=$?
[[ $rc -eq 2 ]] || exit 1
[[ -n "$err" ]] || exit 1
[[ "$err" == *"Traceback"* ]] && exit 1
[[ -f tests/test_missing.py ]] || exit 1

out=$(python3 -m unittest discover -s tests -p "test_*.py" 2>&1) || exit 2
[[ "$out" == *"Ran 0 tests"* ]] && exit 1
exit 0
