# Chapter 11: a tool call that doesn't happen

A `PreToolUse` hook, which is the one place the model can't talk its way past.
Two jobs: a `HALT` file that blocks everything while it exists, and five outcomes
that never happen unattended.

This is the shortest port in the book. The contract is identical on both vendors,
so it's the one row in your Chapter 3 switching-cost table that moves as-is.

## Fire it

```
$ echo '{"tool_input":{"command":"git push --force"}}' | python3 gate.py ; echo "exit $?"
[swap/stop] blocked: force-push over shared history. The command was: git push --force
exit 2
```

And the panic button:

```
$ touch HALT
$ echo '{"tool_input":{"command":"ls"}}' | python3 gate.py ; echo "exit $?"
exit 2
$ rm HALT
```

`HALT.example` ships instead of `HALT`, because a live `HALT` in a repo you just
cloned would block every tool call the moment you wired the hook up.

## What success looks like

You trigger the stop mid-run and confirm on evidence that no further tool call
executed: the hook's own message, **and** the absence of the side effect on disk.
Both. The message alone isn't proof.

## exit 2. Never exit 1

With `exit 1` you get no error, no warning, no log line, no indication of any
kind that your stop exists and did nothing. One is the conventional Unix failure
code. Here it means "carry on." The model will even report that the hook didn't
block, which means it knew more about your guardrail than you did.

## The sandbox, which needs no key at all

```
$ codex sandbox --log-denials -- curl -sS -m 8 https://example.com -o /dev/null
$ codex sandbox -- /bin/sh -c 'echo hi > /tmp/probe.txt'
```

Network blocked, write blocked, and **no model in the loop at all**. Containment
you can demonstrate to somebody in ten seconds.

⚠ On the denials log: it's noisy, not empty. It prints a long list including the
DNS lookup the block actually stopped, and the list length moves between runs on
the same machine. Read it for the entry you care about rather than for a count.
See `GOTCHAS.md`: the book gets this one backwards.

## On your own project

Open `failure-modes.md` and fill in the last column against your own setup. Two
of its five rows are marked "no" on purpose.

Then edit the `NEVER` list. Five rows is a starting point, not an answer: the
right list is the one made of things that have actually gone wrong to you.
