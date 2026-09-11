#!/usr/bin/env bash
# check.sh <workdir> — Chapter 10. Exits 0 only if the job is done.
#   1 = the --min contract is wrong or the new test is missing
#   2 = the test suite failed
#   3 = the work directory is missing
set -uo pipefail
cd "${1:?usage: check.sh <workdir>}" || exit 3

[[ -f tests/test_min.py ]] || exit 1

python3 - <<'PY' || exit 1
import subprocess, sys

def run(*args):
    return subprocess.run([sys.executable, "wordfreq.py", "corpus.txt", *args],
                          capture_output=True, text=True)

base = run()
assert base.returncode == 0, f"plain run exited {base.returncode}"
assert run("--min", "1").stdout == base.stdout, "--min 1 changed the output"

r = run("--min", "3")
assert r.returncode == 0, f"--min 3 exited {r.returncode}"
rows = [ln for ln in r.stdout.splitlines() if ln.strip()]
assert rows, "--min 3 printed nothing at all"
assert len(rows) < len(base.stdout.splitlines()), "--min 3 dropped nothing"
for ln in rows:
    assert int(ln.split("\t")[0]) >= 3, f"kept a row under the threshold: {ln!r}"

bad = run("--min", "banana")
assert bad.returncode == 2, f"bad --min exited {bad.returncode}, wanted 2"
assert bad.stderr.strip(), "bad --min said nothing on stderr"
assert not bad.stdout.strip(), "bad --min still printed to stdout"
PY

out=$(python3 -m unittest discover -s tests -p "test_*.py" 2>&1) || exit 2
[[ "$out" == *"Ran 0 tests"* ]] && exit 1
exit 0
