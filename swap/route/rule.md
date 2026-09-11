# swap/route/rule.md: Chapter 9

One rule, in the form your setup actually reads. Not a paragraph of intent.

Mine is a line in `swap/adapter/models.txt` plus a fallback chain:

```json
{ "fallbackModel": ["claude-sonnet-5", "claude-haiku-4-5"] }
```

The rule behind it: **route to the cheap alias first, and fall back on failure
rather than on a guess about difficulty.** I tried routing on job difficulty and
couldn't write a rule that decided it without reading the job, which is a
judgement, and judgements are what this whole directory replaces with exit
codes.

Write yours against the table `price.py` prints, not against a feeling. The
column that decides it is **cost per finished job**, with the failed reruns
counted in, because an alias that's cheap per run and fails half the time is not
cheap. If an alias reports `never finished`, it has no cost per finished job at
all and no rule should send work to it.
