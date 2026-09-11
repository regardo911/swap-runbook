# Chapter 8: deciding whether "finished" is true

A `Stop` hook. The agent says it's done; this decides, on evidence the model
never produced.

Three checks, in the order they matter: the contract it claims to produce, the
exit code of the suite it says it ran, and the bytes of the file it says it
changed.

## Test it offline first

```
$ SWAP_WORK=../swaptest/fixtures SWAP_BASELINE=../swaptest/fixtures \
    python3 gate.py < /dev/null ; echo "exit $?"
[swap/check] The run claims to be finished. The evidence disagrees:
  - contract: stdout is not JSON …
  - bytes: linecount.py is byte-identical to the baseline
  - bytes: tests/test_json.py does not exist on disk
exit 2
```

Three specific complaints on a directory nobody has touched. **A gate that
passes before the work is done is scenery.**

## What success looks like

A run where the agent says it finished, your setup disagrees, and the run
continues instead of ending.

If you never see it fire, lower the bar until it does. A gate that has never
fired and a gate that doesn't work are indistinguishable from a log file.

## Three details that aren't decoration

`stop_hook_active` stops you building an infinite loop where the gate rejects and
the agent retries forever.

The **`Ran 0 tests`** check exists because a test runner that collects nothing
exits 0, and "the suite passed" with no tests in it is the purest possible form
of a true statement that means nothing.

Every failure message names *what* failed. "Check failed" sends the agent
guessing; `expected keys file+lines, got ['lines', 'path']` sends it to the line.

## Never let the model supply the evidence

The rule the whole chapter hangs on, and it's easy to break by accident. If your
check reads a file the agent wrote to report its own success, you've built a
mirror. Run the command yourself. Read the bytes yourself.

## exit 2, never exit 1

The single most expensive one-character mistake available here. A gate written
with `exit 1` logs beautifully and stops nothing, and the model is never told it
fired.

## On your own project

Three checks is the number. Beyond three or four you're writing a test suite,
and a test suite belongs in your repository where it can be maintained. Pick the
three that catch your actual failures:

1. The output contract, if your job produces one. Biggest failure bucket.
2. The exit code of something that already decides right and wrong for you.
3. Bytes, against a baseline copy the agent can't reach.

Then wire it on `Stop` with `./install.sh`, and make it fire once on purpose.
