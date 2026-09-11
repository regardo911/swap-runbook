#!/usr/bin/env python3
"""
swap/store/store.py — Chapter 7. Run state that lives on disk instead of in the
conversation.
  record   append one finished step. The agent calls this after it does something.
  brief    print a FIXED-SIZE digest: the plan, what is done, what is next.
           This is the only thing the conversation ever sees.
  dump     print everything. For you, never for the model.

    store.py record <step> <status> <note...>
    store.py brief
    store.py dump
"""
import json, pathlib, sys, time

HERE   = pathlib.Path(__file__).resolve().parent
LEDGER = HERE / "steps.jsonl"
PLAN   = HERE / "plan.json"

def steps():
    if not LEDGER.exists():
        return []
    return [json.loads(l) for l in LEDGER.read_text().splitlines() if l.strip()]

def cmd_record(argv):
    step, status = argv[0], argv[1]
    note = " ".join(argv[2:])[:200]        # hard cap: a note is not a log
    with LEDGER.open("a") as f:
        f.write(json.dumps({"ts": int(time.time()), "step": step,
                            "status": status, "note": note}) + "\n")
    print(f"recorded {step}={status}")

def cmd_brief(_argv):
    plan = json.loads(PLAN.read_text())["steps"] if PLAN.exists() else []
    seen = {s["step"]: s for s in steps()}
    # Only plan steps go in the digest. If this iterated over the whole ledger
    # instead, the digest would grow with history and you would be back where
    # you started.
    done = [p for p in plan if seen.get(p, {}).get("status") == "done"]
    todo = [p for p in plan if p not in done]
    print("PLAN:", ", ".join(plan) or "(none)")
    print("DONE:", ", ".join(done) or "(nothing yet)")
    print("NEXT:", todo[0] if todo else "(all steps complete - stop)")
    for s in steps()[-1:]:
        print("LAST:", s["step"], s["status"], s["note"][:80])

def cmd_dump(_argv):
    for s in steps():
        print(json.dumps(s))

CMDS = {"record": cmd_record, "brief": cmd_brief, "dump": cmd_dump}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in CMDS:
        print(f"usage: store.py [{'|'.join(CMDS)}] ...", file=sys.stderr)
        sys.exit(64)
    CMDS[sys.argv[1]](sys.argv[2:])
