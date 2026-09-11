# Chapter 9: what a finished job costs

`runs.tsv` here is synthetic sample data so `price.py` has something to chew on
before you have runs of your own. The shape is real; the numbers are made up.
Replace it the moment you have three runs per alias.

## Run it

```
$ python3 price.py runs.tsv
alias       runs  pass   rate     spent   per finished job
fast           3     2    67%    0.1540            $0.0770
deep           3     3   100%    0.3541            $0.1180
```

No key, no network, no account. It's arithmetic over a text file.

## What success looks like

The cheap alias is not cheaper. `fast` costs less per *run* and more per
*finished job*, because the run that failed still cost money and the next
success had to carry it. That inversion is the entire chapter, and it only shows
up when you divide by passes instead of by runs.

If an alias prints `never finished`, it has no cost per finished job at all.
That's the most useful thing this script can tell you.

## On your own project

1. Append your own rows: `alias`, `pass|fail`, `cost`, `turns`, tab-separated.
   `swap/swaptest/run.sh` and `swap/evalset/run-all.sh` both print rows this
   reads: `price.py` takes the four-column and five-column shapes alike.
2. Run it at three runs per alias minimum. Three isn't statistics, it's enough to
   see whether the pass rate is 100% or something else.
3. Write one rule into `rule.md` in the form your setup actually reads.

## The cap

`cap.py` is the spend halt. There's no shipped dollar ceiling in either CLI —
`rollout_budget` is under development and off, so this is the only one you get.

```
$ SWAP_SPEND_CEILING=0.50 python3 cap.py < event.json
```

**Exit 2 blocks. Every other non-zero exit does nothing, silently.**
