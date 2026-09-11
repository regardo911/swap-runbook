#!/usr/bin/env bash
# call.sh <alias> <prompt-file> <workdir> <raw-out> — Chapter 5.
# Resolve an alias from models.txt, run the right CLI with the right flags, and
# write that CLI's raw structured output to <raw-out>.
# Nothing above this file knows which vendor anything is.
set -uo pipefail
ALIAS="${1:?alias}"; PROMPT_FILE="${2:?prompt file}"
WORKDIR="${3:?workdir}"; RAW="${4:?raw out}"
HERE="$(cd "$(dirname "$0")" && pwd)"

# The prompt path is made absolute up here, on purpose. Both branches below read
# it inside a (cd "$WORKDIR" && ...) subshell, and the shell expands $(cat ...)
# after that cd has already happened. A relative path like job.md resolves
# against the work directory instead of against you, and the CLI silently gets
# an empty prompt.
case "$PROMPT_FILE" in /*) ;; *) PROMPT_FILE="$PWD/$PROMPT_FILE" ;; esac

LINE=$(sed 's/[[:space:]]#.*//' "$HERE/models.txt" | grep -v '^[[:space:]]*#' \
       | awk -v a="$ALIAS" '$1==a {print; exit}')
[[ -z "$LINE" ]] && { echo "adapter: no alias '$ALIAS' in models.txt" >&2; exit 64; }

RUNNER=$(awk '{print $2}' <<<"$LINE")
MODEL=$(awk  '{print $3}' <<<"$LINE")
EXTRA=$(awk  '{ $1=""; $2=""; $3=""; sub(/^ +/,""); print }' <<<"$LINE")

case "$RUNNER" in
  claude)
    (cd "$WORKDIR" && claude -p --model "$MODEL" --output-format json \
        --permission-mode acceptEdits $EXTRA \
        "$(cat "$PROMPT_FILE")" < /dev/null 2>/dev/null) > "$RAW" ;;
  codex)
    (cd "$WORKDIR" && codex exec --json --skip-git-repo-check -s workspace-write \
        -m "$MODEL" $EXTRA \
        "$(cat "$PROMPT_FILE")" < /dev/null 2>/dev/null) > "$RAW" ;;
  *)
    echo "adapter: unknown runner '$RUNNER' for alias '$ALIAS'" >&2; exit 65 ;;
esac
