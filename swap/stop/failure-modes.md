# swap/stop/failure-modes.md: Chapter 11

Five ways a stop looks like a stop and isn't. Rows 1-3 are solved by `gate.py`.
Rows 4 and 5 are not, and they stay on the board precisely because they are not.
A checklist that only contains the rows you solved is a trophy cabinet.

| # | The failure | Does mine hold? | Evidence |
|---|---|---|---|
| 1 | The hook exits **1** instead of 2. Logs beautifully, blocks nothing, and the model is never told it fired | **yes** | `gate.py` exits 2 on every `NEVER` row. Tested offline, no key needed |
| 2 | The hook can't find its script, which looks exactly like a hook that decided not to fire | **yes** | `install.sh` emits absolute paths. That's the whole reason it exists |
| 3 | The `NEVER` list is a comment rather than a matcher | **yes** | Five regexes, each with a test |
| 4 | `PermissionRequest` doesn't honour exit 2 the way `PreToolUse` does | **no** | Not covered. If your enforcement hangs off `PermissionRequest`, verify it yourself before you trust it |
| 5 | A repo-local `.codex/config.toml`: there's an open bug, filed months ago and still unresolved, where hooks configured there don't fire | **no** | Put Codex hooks in `$CODEX_HOME/config.toml`. Not repo-local. This is not a style preference |

**Fire it, or you don't have it.** A gate that has never fired and a gate that
doesn't work are indistinguishable from a log file. Test yours:

```
$ touch swap/stop/HALT
$ echo '{"tool_input":{"command":"ls"}}' | python3 swap/stop/gate.py ; echo "exit $?"
$ rm swap/stop/HALT
```

Exit 2, with a reason on stderr. If you get anything else, the file path in your
settings block is wrong.
