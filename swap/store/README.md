# Chapter 7: run state that isn't the conversation

Three commands. `record` appends one finished step, `brief` prints a fixed-size
digest, `dump` prints everything for you and never for the model.

The digest is the only thing the conversation ever sees. That's what keeps a long
job from paying rent on its own memory.

## Run it

```
$ python3 store.py brief
PLAN: step-1, step-2, step-3, step-4
DONE: (nothing yet)
NEXT: step-1
```

No key, no network. Then record something and look again:

```
$ python3 store.py record step-1 done "wrote the parser"
$ python3 store.py brief
```

## What success looks like

**The digest doesn't grow.** Append two hundred records and measure both files:
the ledger climbs into the tens of kilobytes and `brief` doesn't move after
about the tenth record.

If yours grows, you have the bug I had: iterating over the whole ledger to build
the `DONE` line instead of over the plan, so the summary got longer every time
the agent did anything. **A digest that grows with history is not a digest.**
It's the conversation with extra steps.

`tests/test_swap.py` pins this at 200 records.

## Tell the agent the protocol

Put it in the job, not in your head:

```
You are resuming a job that may already be partly done. Do NOT assume you are
starting fresh.

First, always, run:  python3 swap/store/store.py brief

Then loop: do the ONE step its NEXT line names, record it, and run brief again.
Keep going until NEXT says all steps are complete, then stop and report.

After finishing step X, run:
  python3 swap/store/store.py record X done "<one line about what you produced>"
```

Write that last instruction as a single loop. A draft that says "do one step and
stop" *and* "keep going until complete" is a contradiction, and an agent obeying
the stop is the correct response to it.

## On your own project

1. Write your own `plan.json`: `{"steps": ["...", "..."]}`. The steps are the
   plan; the ledger is history. Only the plan goes in the digest.
2. Paste the protocol above into your job text.
3. Run it from empty. Then delete the session, hand-record the first two steps as
   if the run had crashed, and start a brand new session with the identical
   prompt. Compare what the two cost.

Note the 200-character cap on a note. A note is not a log. Lift it and you've
rebuilt the thing you were escaping.
