`linecount.py` crashes with a traceback when the file it is given does not exist.

Make it exit 2 and print a short error to stderr instead. The message must name
the path it could not read. Nothing should go to stdout on that path, and the
traceback must not appear.

Add a test at `tests/test_missing.py` that runs the program against a path that
does not exist, asserts the exit code is 2, asserts stderr is non-empty, and
asserts "Traceback" is not in stderr. Write it in the same style as the existing
test: a `unittest.TestCase` subclass, standard library only.

Do not change the behaviour for a file that does exist. Do not add dependencies.
