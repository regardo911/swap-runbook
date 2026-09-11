# swap/switching-cost.md: Chapter 3

The same six rows, priced in hours. **Destination named: Codex CLI.** An estimate
against "somewhere else" is a mood, not a number.

**Leaving costs me about three hours today.** That is lower than it feels, and
the reason is row 4: most of what I would be moving is nobody's, so there is
nothing to move.

| Responsibility | If I had to run this work in Codex by Friday | Hours | Which of the five inputs produced it |
|---|---|---|---|
| observation | Rewrite `CLAUDE.md` as `AGENTS.md`. Same content, different filename | 0.5 | config-swap, not a proxy |
| context | Nothing to move. Neither side lets me set a policy | 0 | where state lives: there is no artifact |
| control | Nothing to move. The loop is theirs on both sides | 0 | licence class: closed both ends |
| action | Port one `PostToolUse` hook from JSON to TOML | 1 | does the stop transfer: yes, as-is |
| state ★ | Nothing exists, so nothing ports. The cost isn't migration, it's redoing every long job from the top | 1.5 | where state lives |
| verification | Nothing exists yet | 0 |: |

**★ `state` is the starred row.** It prices at 1.5 hours and it is the most
expensive line on the board, because the number is not what moving costs. It is
what *not having it* costs, every single long job, forever. Chapter 7 turns this
row into a file.

The five inputs, so you can price your own rows: licence class · config-swap or
proxy · does the stop transfer · does the event set transfer · where state lives.

One number worth knowing before you price row 4: on 2.1.268 Claude Code exposes
**33** hook events and on 0.152.0 Codex exposes **12**. Count the events you
actually use that are not in the intersection and put four hours against each,
because each one is a redesign rather than a port.
