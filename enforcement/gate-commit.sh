#!/usr/bin/env bash
# VibeGates gate G7/R-13/R-22 — commit guard.
# Usable as: (a) .git/hooks/pre-commit (no stdin), or (b) an agent-harness PreToolUse
# hook receiving {"tool_input":{"command":"..."}} on stdin (e.g. Claude Code).
# Blocks: (1) `git commit --no-verify` (R-22, harness mode only — plain git hooks
# cannot see the flag); (2) staged diffs introducing naked TODO/FIXME (R-13).
# Exit 2 = block (message on stderr).

set -u
CMD=""
if [ ! -t 0 ]; then
  INPUT="$(cat || true)"
  if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
  fi
fi

if [ -n "$CMD" ]; then
  case "$CMD" in
    *git*commit*) : ;;
    *) exit 0 ;;
  esac
  case "$CMD" in
    *--no-verify*)
      echo "BLOCKED (VibeGates R-22/G7): git commit --no-verify bypasses verification. No exceptions." >&2
      exit 2 ;;
  esac
fi

STAGED="$(git diff --cached -U0 2>/dev/null || true)"
if [ -n "$STAGED" ]; then
  BAD="$(printf '%s\n' "$STAGED" | grep -E '^\+' | grep -Ev '^\+\+\+' | grep -E '\b(TODO|FIXME)\b' || true)"
  if [ -n "$BAD" ]; then
    echo "BLOCKED (VibeGates R-13): staged diff introduces naked TODO/FIXME:" >&2
    printf '%s\n' "$BAD" | head -5 >&2
    echo "Handle before commit: debt register + ADR (deliberate-prudent debt), or resolve the point. A naked owed item is a pass defect." >&2
    exit 2
  fi
fi
exit 0
