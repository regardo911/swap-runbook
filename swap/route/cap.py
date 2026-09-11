#!/usr/bin/env python3
"""
swap/route/cap.py — Chapter 9. A PostToolUse hook that halts a session past a
spend ceiling. There is no shipped dollar cap in either CLI, so this is it.

    SWAP_MAX_USD=1.00 python3 cap.py < event.json

Two limits worth knowing before you trust it. It is one run behind, because the
cost of the current turn is not known until the turn ends, so set the ceiling
below the number that would actually hurt. And it is per session, so five
parallel sessions get five ceilings.
"""
import json, os, pathlib, sys

HERE    = pathlib.Path(__file__).resolve().parent
LEDGER  = HERE / "spend.tsv"          # session_id <TAB> cost, appended per run
MAX_USD = float(os.environ.get("SWAP_MAX_USD", "1.00"))

ev  = json.loads(sys.stdin.read() or "{}")
sid = ev.get("session_id", "")

spent = 0.0
if LEDGER.exists():
    for line in LEDGER.read_text().splitlines():
        cols = line.split("\t")
        if len(cols) >= 2 and cols[0] == sid:
            spent += float(cols[1])

if spent >= MAX_USD:
    print(f"[swap/route] this session has recorded ${spent:.4f} against a "
          f"${MAX_USD:.2f} ceiling. Stop calling tools. Report what you have "
          f"and what is left to do.", file=sys.stderr)
    sys.exit(2)

sys.exit(0)
