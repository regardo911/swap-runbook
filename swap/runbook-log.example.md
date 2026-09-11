# swap/runbook-log.example.md

`swap/runbook-log.md` is the one file this repo doesn't ship, because that one is
yours. It's also the only record of how your setup behaved across models, which
makes it the most valuable file in the directory by the third entry.

Copy the shape, not the numbers. Step 7 of the runbook appends one entry per
launch day.

```
## <alias> — <model string exactly as models.txt has it>

pass@1:              <k>/<n>, 95% CI <lo>% to <hi>%
cost per finished:   $<figure from price.py, failed reruns counted in>
swap test:           <pass|fail>, four numbers from run.sh
guardrails:          <fired|did not fire> — say which one you triggered
verdict:             keep | reject

<One sentence a colleague could disagree with. Not "looks good".>
```

Two rules that make the log worth keeping. **Write the rejects down too**: the
model you rejected in March is the one somebody asks you about in June, and
"we tried it" without a number is an opinion. And **never edit an old entry.** An
entry is what you believed on the evidence you had that day.
