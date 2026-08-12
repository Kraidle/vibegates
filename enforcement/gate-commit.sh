#!/usr/bin/env bash
# VibeGates gate G7/R-13/R-22 — commit guard.
# Usable as: (a) .git/hooks/pre-commit (no stdin), or (b) an agent-harness PreToolUse
# hook receiving {"tool_input":{"command":"..."},"cwd":"..."} on stdin.
# Blocks: (1) `git commit --no-verify` (R-22, harness mode only — plain git hooks
# cannot see the flag); (2) commits that would introduce naked TODO/FIXME (R-13) —
# staged diff, plus working tree & untracked files when the command stages by
# itself (add / -a / -A), since a PreToolUse hook runs BEFORE the command and
# cannot see a not-yet-executed `git add`.
# Known residual limit (inherent to pre-execution semantics): content created AND
# committed inside one compound command is invisible at hook time. The CI layer
# (templates/ci-gates.yml, g5 job) is the backstop — defense in depth.
# Exit 2 = block (message on stderr).

set -u
CMD=""; HOOK_CWD=""
# JSON string extractor: jq when available, GNU-grep -P fallback otherwise
# (jq is frequently absent on Windows Git Bash — measured during release testing).
json_str() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$2" | jq -r "$1 // empty" 2>/dev/null || true
  else
    key="${1##*.}"
    printf '%s' "$2" | grep -oP "\"${key}\"\\s*:\\s*\"\\K(\\\\.|[^\"\\\\])*" 2>/dev/null | head -1 \
      | sed 's/\\\\/\\/g; s/\\"/"/g' || true
  fi
}
if [ ! -t 0 ]; then
  INPUT="$(cat || true)"
  if [ -n "$INPUT" ]; then
    CMD="$(json_str '.tool_input.command' "$INPUT")"
    HOOK_CWD="$(json_str '.cwd' "$INPUT")"
  fi
fi

DIR=""
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
  DIR="$(printf '%s' "$CMD" | sed -nE 's/.*(cd|Set-Location)[[:space:]]+["'"'"']?([^"'"'"';|&]+).*/\2/p' | head -1 | sed 's/[[:space:]]*$//')"
  [ -z "$DIR" ] && DIR="$(printf '%s' "$CMD" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+["'"'"']?([^"'"'"';|&]+).*/\1/p' | head -1 | sed 's/[[:space:]]*$//')"
  [ -z "$DIR" ] && DIR="$HOOK_CWD"
fi
G=(git); [ -n "$DIR" ] && [ -d "$DIR" ] && G=(git -C "$DIR")

# Checker files are excluded from their own scan (same convention as the CI g5 job).
EXCL=':(exclude)enforcement/ :(exclude).github/'
LINES="$("${G[@]}" diff --cached -U0 -- $EXCL 2>/dev/null || true)"
if printf '%s' "$CMD" | grep -qE 'git([[:space:]]+[^[:space:]]+)*[[:space:]]+add\b|[[:space:]]commit[[:space:]][^;|&]*(-a\b|-A\b|--all\b)'; then
  LINES="$LINES
$("${G[@]}" diff HEAD -U0 -- $EXCL 2>/dev/null || true)"
  while IFS= read -r u; do
    [ -z "$u" ] && continue
    case "$u" in enforcement/*|.github/*) continue ;; esac
    p="$u"; [ -n "$DIR" ] && p="$DIR/$u"
    [ -f "$p" ] && LINES="$LINES
$(sed 's/^/+/' "$p" 2>/dev/null || true)"
  done <<EOF_UNTRACKED
$("${G[@]}" ls-files --others --exclude-standard 2>/dev/null || true)
EOF_UNTRACKED
fi

BAD="$(printf '%s\n' "$LINES" | grep -E '^\+' | grep -Ev '^\+\+\+' | grep -E '\b(TODO|FIXME)\b' || true)"
if [ -n "$BAD" ]; then
  echo "BLOCKED (VibeGates R-13): this commit would introduce naked TODO/FIXME:" >&2
  printf '%s\n' "$BAD" | head -5 >&2
  echo "Handle before commit: debt register + ADR (deliberate-prudent debt), or resolve the point. A naked owed item is a pass defect." >&2
  exit 2
fi
exit 0
