# swap/runbook.md: Chapter 12

Run this the day a new model ships. Stop at the first step that fails and fix
that before continuing.

```
SWAP RUNBOOK

0. UPGRADE THE HARNESS FIRST.
   GATE: your CLI can name the new model without a 400.

1. ADD THE ALIAS.  One line in swap/adapter/models.txt.
   GATE: call.sh with a tiny prompt exits 0 and writes valid JSON.

2. CONFIRM WHAT ACTUALLY RAN.  Read modelUsage from the raw output.
   GATE: the model you asked for is in there. It may not be alone.

3. SWAP TEST, ONE JOB.  ./swap/swaptest/run.sh new
   GATE: four numbers, and check.sh returns 0.
         If it will not start, you are done for today. Record why.

4. EVAL SET, TEN JOBS.  ./swap/evalset/run-all.sh new > results-new.tsv
   GATE: a pass@1 AND its 95% confidence interval.

5. PRICE IT.  python3 swap/route/price.py results-new.tsv
   GATE: a cost per finished job, failed runs included.

6. CHECK THE GUARDRAILS STILL FIRE.  Trigger swap/stop with the new alias.
   GATE: the stop blocked, and the side effect does not exist on disk.

7. DECIDE, IN WRITING.  Append to swap/runbook-log.md:
   model, pass@1 + CI, cost per finished job, keep or reject, one sentence why.
   GATE: a sentence a colleague could disagree with.
```

Every gate is a condition rather than a description. That's the difference
between a runbook and a checklist.

**Steps 0 and 7 are the ones people skip and they're the two that cost the
most.** Step 0 is the one that fails most often: a CLI two weeks behind the model
you're testing answers with an HTTP 400 telling you to upgrade, and you find that
out in eleven seconds if you look for it and forty minutes in if you don't.
