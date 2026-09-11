# Contributing

**Fixes are welcome, especially the ones where something here disagrees with a
real machine.** Those are the valuable ones: a flag that changed, an exit code
that behaves differently on your CLI version, a command that the docs print and
the binary doesn't have. Open an issue with the output, not a description of the
output.

**This tree mirrors the book, one folder per chapter**, so every file here is
one a reader has already been walked through end to end. Keep that true and a
fix lands easily. A new part the book never covers is better as your own repo,
where you can explain it properly.

Before you open a PR:

```
python3 -m unittest discover -s tests
```

Everything must pass with no network and no API key. If your change needs
either, it belongs somewhere else.

Two house rules, both inherited from the book:

- **No per-token prices, anywhere.** A printed rate is an expiration date. The
  cost figure comes back from the tool with every run.
- **No month-and-year date stamps.** Version numbers are fine and there are
  plenty. A date in print is an expiry label.

Both are enforced by tests, so you'll find out before a reviewer does.
