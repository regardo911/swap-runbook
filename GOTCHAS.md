# gotchas

things that actually bit while building this, with the output that proves it.
four of these are places where the printed book and a real machine disagree. the
repo ships the version that runs and says so here rather than quietly
contradicting the page you read.

## the book's short check.sh passes before the work is done

ch10 prints a four-line wrapper for a job's evaluator, then five lines later
tells you to run it against untouched fixtures and confirm it fails. it doesn't.

```
$ bash /tmp/book-ch10-wrapper.sh missing-file/fixtures ; echo "exit $?"
exit 0
$ bash /tmp/book-ch10-wrapper.sh dedupe-speed/fixtures ; echo "exit $?"
exit 0
$ bash /tmp/book-ch10-wrapper.sh wordfreq-filter/fixtures ; echo "exit $?"
exit 0
```

all three, bash and zsh alike. the reason is structural: at the starting state
the new test doesn't exist yet, so `unittest discover` collects zero or only
passing tests and returns 0 either way.

the chapter's own prose names the two missing pieces one paragraph later: an
assertion about the artifact, and a check that the suite collected more than zero
tests, and the complete pattern is printed 26 lines further on. every `check.sh`
in `swap/evalset/jobs/` uses that later shape. `tests/test_swap.py` pins it:

```
$ for j in swap/evalset/jobs/*/; do bash "$j/check.sh" "$j/fixtures" >/dev/null 2>&1; echo "$(basename $j) exit $?"; done
missing-file exit 1
dedupe-speed exit 1
wordfreq-filter exit 1
```

## the sandbox denial log is noisy, not empty

ch11 prints a transcript where `--log-denials` reads `None found.` and builds a
caveat on the log being incomplete. run it and the opposite happens:

```
$ codex sandbox --log-denials -- curl -sS -m 8 https://example.com -o /dev/null
curl: (6) Could not resolve host: example.com

=== Sandbox denials ===
(curl) sysctl-read security.mac.lockdown_mode_state
(curl) sysctl-read kern.bootargs
(curl) file-write-data /dev/dtracehelper
(curl) sysctl-read kern.iossupportversion
(curl) mach-lookup com.apple.logd
(curl) mach-lookup com.apple.system.notification_center
(curl) mach-lookup com.apple.SystemConfiguration.configd
(curl) network-outbound /private/var/run/mDNSResponder
```

on codex 0.152.0, the version the appendix pins. that last line is the DNS lookup
the block actually stopped: precisely the thing the book says goes unlogged.

so the honest caveat is the reverse of the printed one: read the log for the
entry you care about, not for a count. **don't count the lines.** the length
moves between runs on one machine, which is its own reason not to trust a number
from it.

## call.sh could not read a relative prompt path

the adapter runs the CLI inside `(cd "$WORKDIR" && ...)` and the shell expands
`$(cat "$PROMPT_FILE")` *after* that cd. so this example, printed in the book's
appendix:

```
$ ./swap/adapter/call.sh <alias> job.md <dir> raw.json
```

resolves `job.md` against the work directory instead of against you, and the
CLI gets an empty prompt. it fails as a bad run rather than as a missing file,
which is worse.

`call.sh` now makes the path absolute before the subshell. it's four lines and
there's a comment on it, because every later runner depends on this file.

## run.sh named a vendor after chapter 5 said it shouldn't

the first version of `swap/swaptest/run.sh` here was ch04's, which calls one
vendor's CLI directly. ch05 step 4 replaces that block with an adapter call, and
the claim that `models.txt` is the only file naming a vendor is false until you
do.

caught by a test that greps the tree for vendor names rather than by reading it:

```
AssertionError: Lists differ: ['swap/swaptest/run.sh: claude'] != []
```

the test stays in. it's the only thing standing between that claim and a slow
drift back.

## the digest grew by one byte and the test was wrong, not the code

`store.py brief` is supposed to be fixed-size. a first test appended 200 records
with notes reading `note 1` … `note 200` and caught it growing 71 → 72 bytes.

that's not history growing the digest. that's `note 200` being one character
longer than `note 50`. the test now holds the note length constant so history is
the only variable, and the digest doesn't move between 10 records and 200.

worth writing down because the failure looked exactly like the bug the chapter
warns about, and wasn't.

## report.py can't be imported

it's a script: it reads `sys.argv` at module level. a test that did
`import report` to reach `wilson()` picked up the test runner's own argv and died
with `FileNotFoundError: 'discover'`.

left as a script, because that's how the book prints it and how you run it. the
test drives it through its output instead, which is what a reader sees anyway.
