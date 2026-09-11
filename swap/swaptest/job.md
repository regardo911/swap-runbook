Add a `--json` flag to `linecount.py`.

With `--json`, the program must print a single JSON object to stdout with
exactly two keys: `file` (the path as given) and `lines` (an integer). Without
the flag, the existing human-readable output must be unchanged.

Add a test at `tests/test_json.py` that runs the program with `--json`, parses
stdout with `json.loads`, and asserts both keys are present and that `lines` is
an int. Write it in the same style as the existing test in `tests/`: a
`unittest.TestCase` subclass, standard library only.

Do not change any other behaviour. Do not add dependencies.
