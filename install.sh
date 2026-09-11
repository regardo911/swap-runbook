#!/usr/bin/env bash
# install.sh — print the four hook blocks with YOUR absolute paths already in
# them, for whichever CLI you actually have. Prints by default and touches
# nothing. --write merges them into your settings, and only with the confirm
# string, and only after taking a backup.
#
# Absolute paths are the whole reason this exists. Appendix B2 of the book:
# "a hook that cannot find its script fails in a way that looks exactly like a
# hook that decided not to fire." A relative path in a hook block is the most
# common way to spend an afternoon debugging a gate that was never running.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
WRITE=0
CONFIRM=""
TARGET="both"

while [ $# -gt 0 ]; do
  case "$1" in
    --write)   WRITE=1 ;;
    --confirm) CONFIRM="${2:-}"; shift ;;
    --claude)  TARGET="claude" ;;
    --codex)   TARGET="codex" ;;
    -h|--help)
      sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
      echo
      echo "usage: ./install.sh [--claude|--codex] [--write --confirm I_HAVE_READ_THIS]"
      exit 0 ;;
    *) echo "install.sh: unknown argument '$1'" >&2; exit 64 ;;
  esac
  shift
done

echo "swap/ lives at: $HERE"
echo

# ---------------------------------------------------------------- what you have
PY=$(command -v python3 || true)
if [ -z "$PY" ]; then
  echo "python3:  NOT ON PATH. Everything in swap/ is standard library, so this"
  echo "          is the one thing you must fix before anything here runs."
else
  PYV=$("$PY" -c 'import sys; print("%d.%d" % sys.version_info[:2])')
  OK=$("$PY" -c 'import sys; print("yes" if sys.version_info[:2] >= (3, 9) else "no")')
  if [ "$OK" = yes ]; then
    echo "python3:  $PYV at $PY — fine, the floor is 3.9"
  else
    echo "python3:  $PYV at $PY — BELOW the 3.9 floor. Upgrade before wiring anything."
  fi
fi

HAVE_CLAUDE=0; HAVE_CODEX=0
command -v claude >/dev/null 2>&1 && HAVE_CLAUDE=1
command -v codex  >/dev/null 2>&1 && HAVE_CODEX=1
[ "$HAVE_CLAUDE" = 1 ] && echo "claude:   $(command -v claude)" || echo "claude:   not on PATH"
[ "$HAVE_CODEX"  = 1 ] && echo "codex:    $(command -v codex)"  || echo "codex:    not on PATH"

if [ "$HAVE_CLAUDE" = 0 ] && [ "$HAVE_CODEX" = 0 ]; then
  echo
  echo "Neither CLI is on PATH. The blocks below are still correct — you can"
  echo "paste them once you install one. Everything in swap/ that parses, prices,"
  echo "meters or gates runs right now without either."
fi

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CODEX_CONFIG="${CODEX_HOME:-$HOME/.codex}/config.toml"

# ------------------------------------------------------------------- the blocks
render_claude() {
  cat <<JSON
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command",
                     "command": "/usr/bin/env python3 $HERE/swap/stop/gate.py" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command",
                     "command": "/usr/bin/env python3 $HERE/swap/budget/meter.py" },
                   { "type": "command",
                     "command": "/usr/bin/env python3 $HERE/swap/route/cap.py" } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command",
                     "command": "SWAP_WORK=$HERE/swap/swaptest/work SWAP_BASELINE=$HERE/swap/swaptest/fixtures /usr/bin/env python3 $HERE/swap/check/gate.py" } ] }
    ]
  }
}
JSON
}

render_codex() {
  cat <<TOML
[[hooks.PreToolUse]]
matcher = "^Bash\$"

[[hooks.PreToolUse.hooks]]
type = "command"
command = '/usr/bin/env python3 $HERE/swap/stop/gate.py'
timeout = 30
statusMessage = "Checking the boundary"

[[hooks.PostToolUse]]
matcher = "^Bash\$"

[[hooks.PostToolUse.hooks]]
type = "command"
command = '/usr/bin/env python3 $HERE/swap/budget/meter.py'
timeout = 30
statusMessage = "Metering tool output"
TOML
}

if [ "$TARGET" = both ] || [ "$TARGET" = claude ]; then
  echo
  echo "--- Claude Code: merge into $CLAUDE_SETTINGS ---"
  render_claude
fi
if [ "$TARGET" = both ] || [ "$TARGET" = codex ]; then
  echo
  echo "--- Codex: append to $CODEX_CONFIG ---"
  echo "# Not a repo-local .codex/config.toml. There is an open bug where hooks"
  echo "# configured there do not fire. This path, or it will not run."
  render_codex
fi

# -------------------------------------------------------------------- the write
if [ "$WRITE" = 0 ]; then
  echo
  echo "Nothing was written. Copy a block above, or re-run with:"
  echo "  ./install.sh --write --confirm I_HAVE_READ_THIS"
  exit 0
fi

if [ "$CONFIRM" != "I_HAVE_READ_THIS" ]; then
  echo >&2
  echo "install.sh: --write needs --confirm I_HAVE_READ_THIS as well." >&2
  echo "A flag on its own is not enough to put a hook into your agent config." >&2
  exit 65
fi

STAMP=$(date +%s)
wrote_any=0

if [ "$TARGET" = both ] || [ "$TARGET" = claude ]; then
  mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
  if [ -f "$CLAUDE_SETTINGS" ]; then
    cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.bak.$STAMP"
    echo
    echo "backed up: $CLAUDE_SETTINGS.bak.$STAMP"
    render_claude > "$CLAUDE_SETTINGS.swap-hooks.json"
    echo "WROTE:     $CLAUDE_SETTINGS.swap-hooks.json"
    echo "Your settings already exist and this does not guess at merging JSON."
    echo "Open both and move the hooks block across yourself."
  else
    render_claude > "$CLAUDE_SETTINGS"
    echo
    echo "WROTE:     $CLAUDE_SETTINGS (it did not exist)"
  fi
  wrote_any=1
fi

if [ "$TARGET" = both ] || [ "$TARGET" = codex ]; then
  mkdir -p "$(dirname "$CODEX_CONFIG")"
  if [ -f "$CODEX_CONFIG" ]; then
    cp "$CODEX_CONFIG" "$CODEX_CONFIG.bak.$STAMP"
    echo
    echo "backed up: $CODEX_CONFIG.bak.$STAMP"
  fi
  { echo; echo "# --- swap/ hooks ---"; render_codex; } >> "$CODEX_CONFIG"
  echo "APPENDED:  $CODEX_CONFIG"
  wrote_any=1
fi

[ "$wrote_any" = 1 ] && {
  echo
  echo "Now fire one, because a gate that has never fired and a gate that does"
  echo "not work look identical:"
  echo "  touch $HERE/swap/stop/HALT"
  echo "  # ask your agent to run any shell command. it should be blocked."
  echo "  rm $HERE/swap/stop/HALT"
}
