#!/usr/bin/env python3
"""wordfreq.py — print each word in a file and how often it appears."""
import re
import sys
from collections import Counter

WORD = re.compile(r"[a-z']+")


def counts(text):
    return Counter(WORD.findall(text.lower()))


def main(argv):
    if len(argv) < 2:
        print("usage: wordfreq.py <file> [--min N]", file=sys.stderr)
        return 2
    with open(argv[1], encoding="utf-8") as fh:
        c = counts(fh.read())
    for word, n in sorted(c.items(), key=lambda kv: (-kv[1], kv[0])):
        print(f"{n}\t{word}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
