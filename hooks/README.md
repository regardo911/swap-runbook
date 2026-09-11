# The settings blocks, both vendors

These are the blocks with `/abs/path/` left in as a literal. **Don't paste them
as they are.** Run `./install.sh` from the repo root instead and it prints the
same blocks with your own absolute path already substituted.

They're here because the book's Appendix B2 says the repository contains them,
and because you may want to read the shape before you run anything.

Four parts are hooks and need wiring rather than running: the meter on
`PostToolUse`, the spend cap on `PostToolUse`, the claim checker on `Stop`, and
the stop on `PreToolUse`.

The rule is the same on both sides: **exit 2 blocks with the reason on stderr,
and every other non-zero exit is a non-blocking error, so execution continues.**
A hook you wrote with `exit 1` will log everything, block nothing, and never tell
you.

⚠ Codex hooks go in `$CODEX_HOME/config.toml`, not a repo-local
`.codex/config.toml`. There's an open bug where the repo-local ones don't fire.
