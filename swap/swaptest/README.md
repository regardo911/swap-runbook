# Chapter 4: one job, two models, four numbers

The first win, and it's deliberately uncomfortable. You take one real job you
already hand an agent and run it end to end on two different models, recording
what came back.

Most readers find out here that the second run doesn't start at all. That isn't a
failure. That's the finding.

## Run it

```
$ ./run.sh fast
$ ./run.sh deep
```

Each prints one row:

```
fast       pass                 in=<n>      out=<n>    turns=<n>  <n>s  $<n>
```

Four numbers and a pass flag. `fast` and `deep` come from
`../adapter/models.txt`: edit that file, not this script.

⚠ This one calls a model. It needs your own CLI and spends your own allowance.

## What success looks like

Two complete rows, from two different aliases, produced by a script rather than
by you watching a terminal. If the second alias never started, write down why and
go to Chapter 5. That's the chapter about fixing exactly that.

Before you spend anything, run the negative control:

```
$ ./check.sh fixtures ; echo "exit $?"
exit 1
```

**Exit 1 is correct.** `--json` doesn't exist yet, so the checker says the job
isn't done. A checker that passes before the work is done isn't a checker, and
this is the ten-second test that catches it.

## Reading the four numbers

- **The pass flag** is the only binary one and the only one you act on first. A
  model that fails your checker isn't rescued by being cheap.
- **Input tokens** tell you about your setup, not the model. They're system
  instructions, tool schemas and the conversation being re-sent every turn.
  `sheet.py` sums `input_tokens` + `cache_read_input_tokens` +
  `cache_creation_input_tokens`: the first one alone can read about 90 on a run
  whose real total is over a quarter of a million.
- **Output tokens** are the model's style and cost the most per unit.
- **Wall-clock** is the one you'll care about most and should care about least.
  A three-second gap is your network.

If two models come back within about fifteen percent of each other you've
measured noise. Run the same alias twice and see your own repeat spread before
you believe any gap.

## On your own project

1. Replace `fixtures/` with the starting state of a real job of yours. Anything
   outside `fixtures/` is never touched by a run.
2. Rewrite `job.md`. Three rules: small enough to run three times, deterministic
   enough that a script can decide it, and real. "Make the code better" is not a
   job: nothing can settle it.
3. Rewrite `check.sh` with **distinct exit codes per failure mode**. "The
   contract is wrong" and "the tests broke" are different findings and you'll
   want to tell them apart at three in the morning.
4. Run `./check.sh <your fixtures>` and confirm it **fails** before you run any
   model at all.
5. Then `./run.sh fast`, `./run.sh deep`, and append the rows to a file. A
   terminal you closed can't tell you whether things got better.
