# swap/stop-here.md: Chapter 12

What this will never own. Read it before you add anything.

The man who wrote the thread Chapter 12 is built on spent 883 commits and eight
months building all of it at once, then archived the lot. His diagnosis wasn't
technical: *"I spent more time researching, planning, and adding systems than
actually using the thing to get work done."* This file is the defence against
that, and it only works if you write your own.

Mine, with the crossed-out rows left in. Those are the ones I wanted and talked
myself out of, and they're the useful part of the exercise.

## Never

1. **A retry policy.** Deciding "try again" versus "this will never work" needs
   to interpret the failure. Everything here works because it replaced a
   judgement with an exit code. Where there's no exit code, the trick doesn't
   apply.
2. **Browser automation.** Route around it. Use the API when one exists and
   treat a browser agent as a last resort with a manual fallback.
3. **Cross-session coordination.** Two sessions that can't see each other is a
   real problem and a scheduler is not a weekend.
4. **A prompt optimiser.** Whether the output got better is the judgement I keep
   saying I won't automate.
5. **A model-quality score.** The eval set gives a pass rate on my jobs. A score
   that claims to rank models in general is somebody else's leaderboard, and
   Chapter 1's Spearman −0.05 is what those are worth.

## ~~Nearly~~

- ~~A dashboard over `runs.tsv`~~: `price.py` prints six lines. A dashboard is a
  web app I'd maintain forever to avoid reading six lines.
- ~~Auto-tuning the ceiling in `meter.py`~~: I'd be tuning a number I look at
  twice a month.
- ~~A plugin system for `check.sh`~~: there are three checkers. Three.
- ~~Wrapping all of this in a CLI~~. It's already a directory of commands. A CLI
  would be a layer between me and the thing, which is the entire problem.
- ~~A config file to unify the two vendors' settings~~. This is the one I wanted
  most. It's also a format-translating proxy, which Chapter 3 prices in days.

The test for adding a row: **can a command settle whether it worked?** If not, it
belongs here rather than in the directory.
