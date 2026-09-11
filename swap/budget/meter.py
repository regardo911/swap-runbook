#!/usr/bin/env python3
"""
swap/budget/meter.py — Chapter 6. A PostToolUse hook. Two jobs:
  1. METER   every tool result gets a row in ledger.tsv.
  2. EVICT   a result bigger than MAX_TOOL_BYTES is spilled to a file and
             replaced with a one-line pointer, so the payload never enters
             the conversation and never gets re-sent on every later turn.
Exit 0 lets the result through. Exit 2 replaces it with what this script
writes to stderr. Any OTHER non-zero exit is a non-blocking error and the
result goes through unchanged.

Reads the event on stdin, so you can test both branches offline:
    echo '{"session_id":"t1","tool_name":"Bash","tool_response":"x"}' | meter.py
"""
import json, os, pathlib, sys, time

HERE = pathlib.Path(__file__).resolve().parent
MAX_TOOL_BYTES = int(os.environ.get("SWAP_MAX_TOOL_BYTES", "20000"))
TURN_CEILING   = int(os.environ.get("SWAP_TURN_CEILING", "400000"))

ev   = json.loads(sys.stdin.read())
tool = ev.get("tool_name", "?")
body = json.dumps(ev.get("tool_response", ""), ensure_ascii=False)
size = len(body.encode())

ledger = HERE / "ledger.tsv"
if not ledger.exists():
    ledger.write_text("unix_ts\tsession\ttool\tbytes\trunning\tverdict\n")

running = size
for line in ledger.read_text().splitlines()[1:]:
    cols = line.split("\t")
    if len(cols) >= 5 and cols[1] == ev.get("session_id", ""):
        running += int(cols[3])

verdict = "pass"
if size > MAX_TOOL_BYTES:
    verdict = "evicted"
elif running > TURN_CEILING:
    verdict = "ceiling"

with ledger.open("a") as f:
    f.write(f"{int(time.time())}\t{ev.get('session_id','')}\t{tool}\t"
            f"{size}\t{running}\t{verdict}\n")

if verdict == "evicted":
    spill = HERE / "spill" / f"{ev.get('tool_use_id','x')}.txt"
    spill.parent.mkdir(exist_ok=True)
    spill.write_text(body)
    print(f"[swap/budget] {tool} returned {size} bytes, over the "
          f"{MAX_TOOL_BYTES}-byte ceiling. The output was NOT added to the "
          f"conversation. It is on disk at {spill}. Read the part you need "
          f"with grep, head or sed. Do not cat the whole file.", file=sys.stderr)
    sys.exit(2)

if verdict == "ceiling":
    print(f"[swap/budget] this session has spent {running} bytes of tool "
          f"output against a {TURN_CEILING}-byte ceiling. Stop calling tools "
          f"and report what you have.", file=sys.stderr)
    sys.exit(2)

sys.exit(0)
