# Chapter 6: what your setup costs before it reads your task

A `PostToolUse` hook. It writes a row per tool call into `ledger.tsv`, and when a
result comes back bigger than the ceiling it spills the payload to a file and
replaces it with a pointer, so the bytes never enter the conversation and never
get re-sent on every later turn.

## Test it offline first, with no model in the loop

```
$ echo '{"session_id":"t1","tool_name":"Bash","tool_use_id":"u1",
         "tool_response":{"stdout":"'"$(python3 -c 'print("x"*30000)')"'"}}' \
    | SWAP_MAX_TOOL_BYTES=20000 python3 meter.py ; echo "exit $?"
[swap/budget] Bash returned 30014 bytes, over the 20000-byte ceiling. …
exit 2
```

Then a small one, and confirm exit 0. **If either exit code is wrong, stop
here.** A budget you can't test without spending money is a budget you'll never
tune.

## What success looks like

`ledger.tsv` has a row per tool call with a byte count and a verdict, and at
least one row says `evicted`. You can say where the bytes went, because they're
in `spill/`.

## exit 2, not 1

The exit code is the whole mechanism. In both CLIs **exit 2 blocks or replaces,
and every other non-zero exit is a non-blocking error, so execution continues.**
A meter written with `exit 1` will log everything, block nothing, and never tell
you.

## Two ceilings

`SWAP_MAX_TOOL_BYTES` (default 20000) is per result. `SWAP_TURN_CEILING`
(default 400000) is the running total for a session. Both are environment
variables so you can tune them without editing the script.

Don't expect a vendor to do this for you. `token_budget` shows as **under
development** and **false** in `codex features list`, and so does
`rollout_budget`. That absence is why this file exists.

## On your own project

Wire it with `./install.sh` from the repo root, which prints the block with your
absolute path in it. Then run something that produces a lot of output and watch
the ledger fill.

Start with the ceiling too low on purpose. A ceiling that has never fired and a
ceiling that doesn't work look identical.
