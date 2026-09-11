#!/usr/bin/env python3
"""
swap/stop/gate.py — Chapter 11. A PreToolUse hook. Two jobs, in this order:
  HALT   if swap/stop/HALT exists, no tool call runs until you delete it.
  NEVER  the five outcomes that do not happen unattended.
exit 2 blocks the call with the reason on stderr. Any OTHER non-zero exit is a
non-blocking error and the call goes through anyway, which is the trap.

    echo '{"tool_input":{"command":"git push --force"}}' | python3 gate.py
"""
import json, pathlib, re, sys

HERE = pathlib.Path(__file__).resolve().parent
HALT = HERE / "HALT"

NEVER = [
    (r"\bgit\s+push\b.*(--force|-f)\b",   "force-push over shared history"),
    (r"\bgit\s+reset\s+--hard\b",         "discards uncommitted work"),
    (r"\brm\s+-rf?\s+[~/]",               "recursive delete outside the tree"),
    (r"\b(DROP|TRUNCATE)\s+(TABLE|DATABASE)\b", "destructive schema change"),
    (r"\bcurl\b[^|]*\|\s*(sh|bash)\b",    "pipes the internet into a shell"),
]

ev = json.loads(sys.stdin.read() or "{}")

if HALT.exists():
    print(f"[swap/stop] HALT file present at {HALT}. Every tool call is "
          f"blocked. Stop working and report where you got to.", file=sys.stderr)
    sys.exit(2)

cmd = (ev.get("tool_input") or {}).get("command", "")
for pattern, why in NEVER:
    if re.search(pattern, cmd, re.IGNORECASE):
        print(f"[swap/stop] blocked: {why}. The command was: {cmd[:160]}",
              file=sys.stderr)
        sys.exit(2)

sys.exit(0)
