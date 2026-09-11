# Chapter 10: a pass rate on your own jobs

Three jobs, a runner, and a report. The day a new model ships you type one
command, wait, and get a pass rate on **your work** rather than on somebody's
benchmark.

**The runner is the commodity. Your jobs are the product.** Harbor is excellent
and free and somebody else maintains it. The thing nobody can build for you is
the set of tasks that represents your work, with an evaluator that settles each
one. That's what survives every model launch, every CLI upgrade and every change
of employer.

## Run it

```
$ ./run-all.sh fast > results.tsv
$ ./run-all.sh deep >> results.tsv
$ python3 report.py results.tsv
alias        n  pass  pass@1           95% CI     spent  per finished
fast         3     3    100%      44% to 100%    <spend>      $<figure>
```

⚠ `run-all.sh` calls a model and spends your own allowance. `report.py` doesn't —
it's arithmetic over a TSV and runs with no key at all.

## What success looks like

One command returns a pass rate **with an interval** for any alias you point it
at.

Read that interval before you act on the number. Three for three is 100% and
also "anywhere from 44% up", which is the honest version of the same fact. If
people running five thousand rollouts publish a confidence interval, you need one
at three.

If every job passes on every alias, `report.py` says so and tells you to add a
harder job. A set nothing can fail measures nothing.

## The three jobs here

| Job | What the model has to do |
|---|---|
| `missing-file` | Make a crash into a clean exit 2 with a message, and prove it with a test |
| `dedupe-speed` | Make an O(n²) function fast without changing what it returns |
| `wordfreq-filter` | Add a flag with an exact contract, including how it fails |

Each is small, self-contained, has a known good outcome and a scriptable
evaluator. None of them names its own solution: a job that says "use a set" tests
whether the model can follow instructions.

## Every checker fails its own untouched fixtures

Run the negative control before you trust a single number:

```
$ for j in jobs/*/; do bash "$j/check.sh" "$j/fixtures" >/dev/null 2>&1; echo "$j exit $?"; done
```

Every one must be non-zero. **A checker that passes before the work is done will
quietly turn your whole evaluation set into a machine that reports 100 percent
forever.**

⚠ The short wrapper the book prints for this (`cd`, `unittest discover`, `exit 0`)
exits **0** here on all three jobs, so it does not survive its own negative
control. These checkers use the complete pattern the chapter prints later, with
the two assertions its prose names. `GOTCHAS.md` has the run output.

## On your own project

Ten jobs from your own history. Three sources, in order of quality: **your gate
failures from Chapter 8** (every one is a reproducible disagreement you already
found), **your git history**, and **the thing that broke last month**.

Turning one commit into one job:

```bash
$ git log --format='%h %s' --diff-filter=M --since='6 months ago' -- '*test*' | head -40
$ git show --stat <sha> | tail -3          # two or three files, under ~80 lines
$ git worktree add /tmp/job-fixtures <sha>^
```

The parent commit is a perfect starting fixture, because you know for a fact the
job was doable from there: somebody did it. Copy out the two files the commit
touched plus whatever they import. Keep it small.

Then write `job.md` from the commit message and **make it worse**: strip anything
naming the solution, keep what names the requirement. Add the contract
explicitly: the function signature, the exit code, the output shape, the file
path. Every one you leave implicit is a coin flip you paid for.

Two mistakes worth avoiding, both cheap: a commit whose test depended on a
service that no longer exists (unpassable, quietly reports every model as
broken), and one where the fix was a version bump (everything passes instantly,
tells you nothing). **A job nothing can pass and a job everything passes are
equally useless.**

## Scaling past this

If you already run a benchmark suite, use it instead of what's here:

```
$ uv tool install harbor
$ harbor run -d terminal-bench/terminal-bench@4.0.0 -e modal -a claude-code -m <model> -k 5
```

Docker is a hard requirement and the failure is immediate: it doesn't get as far
as looking at your arguments. That's exactly why this directory runs on the
runner you already have instead.

The agents are an enum on `-a`, visible in `harbor run --help`. Check the flag
rather than a tutorial page.
