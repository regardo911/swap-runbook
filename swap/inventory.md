# swap/inventory.md: Chapter 2

Six responsibilities, an owner and a piece of evidence on each. This is a filled
copy so you know what done looks like. **Yours will differ, and the differences
are the whole point.** Copy this file, wipe the three right-hand columns, and
fill them in against the setup you ran this morning.

Totals: **mine 2 · vendor 3 · nobody 1**

| Responsibility | What does it in my setup | Who controls it | Evidence |
|---|---|---|---|
| observation | The CLI's own file reads and command output, plus a `CLAUDE.md` of about 90 lines | vendor | `claude doctor` lists the hook events; nothing in my tree decides what gets read |
| context | The vendor's window management and compaction | vendor | No file of mine sets a window policy. `token_budget` is under development and **false** in `codex features list` |
| control | The agent loop, closed | vendor | I cannot point at a file that decides the next step |
| action | The shipped tool set, plus one `PostToolUse` hook of mine | **mine** | `.claude/settings.json`: the hook is a file I edit today |
| state | Nothing | **nobody** | Grepped the repo for any file written between turns. There is no such file. Run history lives in the conversation and is re-sent every turn |
| verification | Nothing until Chapter 8 | **nobody** | No `Stop` hook. The agent's "done" was the only check |

The two **nobody** rows are the finding. They are the ones Chapters 7 and 8 turn
into files.

## Evidence

Paste the raw output of both commands here. Don't summarise it: the point of
this section is that it isn't your opinion.

```
$ claude doctor
(paste yours)

$ codex features list
(paste yours)
```

Put a deliberately wrong hook event in your settings before you run `claude doctor`
and it prints all 33 valid event names back at you. That's a free, offline way to
find out what your CLI will actually listen for.
