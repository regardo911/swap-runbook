#!/usr/bin/env python3
"""linecount.py — print how many lines are in a file.

The starting state for Chapter 4's swap test. It works, it has a test, and it
does not have the --json flag the job asks for. That absence is the point:
check.sh exits 1 against this directory before any model touches it.
"""
import sys


def count_lines(path):
    with open(path, encoding="utf-8") as fh:
        return sum(1 for _ in fh)


def main(argv):
    if len(argv) < 2:
        print("usage: linecount.py <file>", file=sys.stderr)
        return 2
    path = argv[1]
    print(f"{path}: {count_lines(path)} lines")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
