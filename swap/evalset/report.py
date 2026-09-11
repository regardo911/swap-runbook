#!/usr/bin/env python3
"""
swap/evalset/report.py — Chapter 10. Turn run-all.sh's rows into a pass rate
with an interval. Reads the five columns run-all.sh prints, one row per job per
alias: alias, job, pass|fail, cost, seconds.

    ./run-all.sh fast > results.tsv && ./run-all.sh deep >> results.tsv
    python3 report.py results.tsv
"""
import math
import sys
from collections import defaultdict


def wilson(k, n, z=1.96):
    """Binomial confidence interval. Wilson score, because the textbook
    normal approximation is badly wrong at n = 10, which is our n."""
    if n == 0:
        return (0.0, 0.0)
    p = k / n
    d = 1 + z * z / n
    centre = (p + z * z / (2 * n)) / d
    half = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / d
    return (max(0.0, centre - half), min(1.0, centre + half))


rows = defaultdict(list)
for line in open(sys.argv[1] if len(sys.argv) > 1 else "results.tsv"):
    if not line.strip():
        continue
    alias, job, verdict, cost, secs = line.rstrip("\n").split("\t")
    rows[alias].append((verdict, float(cost)))

print(f"{'alias':<10} {'n':>3}  {'pass':>4}  {'pass@1':>6}  "
      f"{'95% CI':>15}  {'spent':>8}  {'per finished':>12}")

clean_sweep = True
for alias, rs in rows.items():
    n = len(rs)
    k = sum(1 for v, _ in rs if v == "pass")
    spent = sum(c for _, c in rs)
    lo, hi = wilson(k, n)
    per = f"${spent / k:.4f}" if k else "never finished"
    print(f"{alias:<10} {n:>3}  {k:>4}  {k / n:>6.0%}  "
          f"{f'{lo:.0%} to {hi:.0%}':>15}  {spent:>8.4f}  {per:>12}")
    if k != n:
        clean_sweep = False

if clean_sweep:
    print("\nEvery job passed on every alias. Your set is too easy — "
          "add a harder job.")
