`dedupe()` in `dedupe.py` takes about eight seconds on the 50,000-row fixture in
`rows.txt`. It must take under one second, and it must still return the unique
rows in the order they were first seen.

`dedupe(rows)` keeps its signature: it takes a list of strings and returns a list
of strings.

Add a test at `tests/test_dedupe_order.py` that builds a list with repeats,
calls `dedupe`, and asserts the result is exactly the first-seen order with no
duplicates. Write it in the same style as the existing test: a
`unittest.TestCase` subclass, standard library only.

Do not add dependencies. Do not change the public name or signature.
