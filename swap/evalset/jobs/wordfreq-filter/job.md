`wordfreq.py` prints every word and its count. Add a `--min <n>` flag that drops
any word appearing fewer than n times.

`--min` takes an integer. Without the flag the output must be unchanged. With
`--min 1` the output must also be unchanged. Counting stays case-insensitive and
the sort order stays as it is: count descending, then the word alphabetically.

A `--min` value that is not an integer must exit 2 with a message on stderr and
nothing on stdout.

Add a test at `tests/test_min.py` that runs the program with `--min` against
`corpus.txt`, asserts every printed count is at or above the threshold, and
asserts a bad `--min` value exits 2. Write it in the same style as the existing
test: a `unittest.TestCase` subclass, standard library only.

Do not add dependencies.
