#!/usr/bin/env python3
"""
swap/route/price.py — Chapter 9. Price a FINISHED job, with the runs that
failed folded in.

    cost per finished job = everything you spent on that alias
                            -------------------------------------
                            the number of runs that actually passed

A run that failed is not free and it is not a separate budget line. It is part
of what the next success cost you.

    price.py <runs.tsv>          defaults to runs.tsv in the current directory

There are no per-token rates in this file. The cost figure comes back from your
own tool with every run, so there is nothing here to look up and nothing to go
stale.
"""
import sys
from collections import defaultdict

rows = defaultdict(list)
for line in open(sys.argv[1] if len(sys.argv) > 1 else "runs.tsv"):
    if not line.strip():
        continue
    # Read from the right-hand end, so this takes both the swap test's
    # alias/verdict/cost/turns row and the eval set's extra job-name column.
    cols = line.rstrip("\n").split("\t")
    alias, verdict, cost = cols[0], cols[-3], cols[-2]
    rows[alias].append((verdict, float(cost)))

print(f"{'alias':<10} {'runs':>5} {'pass':>5} {'rate':>6} {'spent':>9} "
      f"{'per finished job':>18}")
for alias, rs in rows.items():
    n = len(rs)
    p = sum(1 for v, _ in rs if v == "pass")
    spent = sum(c for _, c in rs)
    per = f"${spent / p:.4f}" if p else "never finished"
    print(f"{alias:<10} {n:>5} {p:>5} {p / n:>6.0%} {spent:>9.4f} {per:>18}")
