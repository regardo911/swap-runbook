#!/usr/bin/env python3
"""dedupe.py — drop repeated rows, keep the order they were first seen in."""
import sys


def dedupe(rows):
    out = []
    for row in rows:
        if row not in out:
            out.append(row)
    return out


def main(argv):
    if len(argv) < 2:
        print("usage: dedupe.py <file>", file=sys.stderr)
        return 2
    with open(argv[1], encoding="utf-8") as fh:
        rows = [line.rstrip("\n") for line in fh]
    for row in dedupe(rows):
        print(row)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
