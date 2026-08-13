#!/usr/bin/env bash
# VibeGates gate G1/R-1/R-4 — model-pinning linter (ADR-0002).
# A bare model tier (opus, sonnet, haiku, fable, inherit, default, opusplan)
# resolves to whatever the platform decides at call time. Measured incident,
# 2026-08-05: a bare `opus` in an agent definition silently resolved to a
# service variant of a different model than the one policy required; recurred
# 2026-08-13 through an agent-tool tier enum. Pinned identifiers only
# (e.g. claude-opus-5, claude-haiku-4-5-20251001). Tier matching is case-
# insensitive; the ADR- reference token is case-SENSITIVE (uppercase convention).
# Scans: the YAML FRONTMATTER (first `---` block) of .claude/agents/**/*.md and
#        .claude/skills/**/*.md — body prose and code examples are not linted;
#        .claude/settings.json and .claude/settings.local.json.
# Exemption, visible at point of use (R-23: an undocumented exception is a
# defect): a bare tier passes only if its own line carries an ADR reference —
#   frontmatter:  model: fable   # ADR-0003
#   JSON (no comments): list the value in .claude/model-exceptions.txt, one
#   per line, each line carrying its ADR reference:  advisorModel=fable ADR-0003
#   (the value must be followed by whitespace or end-of-line: an exception for
#   `opusplan` never exempts `opus` — boundary proven by fixture, G2 review.)
# Known residual limit: values built dynamically (env expansion, scripts) are
# invisible to a textual linter; the resolution control at first launch
# (R-1, pass methodology §1.5) remains mandatory and is not replaced by this.
# Usage: lint-model-pinning.sh [repo-root]     Exit 2 = block.

set -u
ROOT="${1:-.}"
TIERS='opus|sonnet|haiku|fable|inherit|default|opusplan'
EXCEPTIONS="$ROOT/.claude/model-exceptions.txt"
FAIL=0
SCANNED=0

# 1) Frontmatter `model:` in agent/skill definitions — bare tier without ADR ref
#    on the line. Only the leading `---` block is scanned (original line numbers kept).
while IFS= read -r f; do
  [ -f "$f" ] || continue
  SCANNED=$((SCANNED + 1))
  FM="$(awk 'NR==1 { if ($0 !~ /^---[[:space:]]*$/) exit; fm=1; next }
             fm    { if ($0 ~ /^---[[:space:]]*$/) exit; print NR ":" $0 }' "$f")"
  [ -z "$FM" ] && continue
  HITS="$(printf '%s\n' "$FM" | grep -iE "^[0-9]+:[[:space:]]*model:[[:space:]]*[\"']?(${TIERS})[\"']?[[:space:]]*(#.*)?$" | grep -v 'ADR-' || true)"
  if [ -n "$HITS" ]; then
    FAIL=1
    echo "BLOCKED (VibeGates R-1/R-4): bare model tier in $f — pin the exact identifier or annotate the line with its ADR:" >&2
    printf '%s\n' "$HITS" | head -5 >&2
  fi
done <<EOF_FILES
$(find "$ROOT/.claude/agents" "$ROOT/.claude/skills" -name '*.md' 2>/dev/null)
EOF_FILES

# 2) Settings JSON — "model"/"advisorModel" bare-tier values, unless excepted
#    with an ADR ref. Every key:value pair on a line is checked, not only the first.
for f in "$ROOT/.claude/settings.json" "$ROOT/.claude/settings.local.json"; do
  [ -f "$f" ] || continue
  SCANNED=$((SCANNED + 1))
  PAIRS="$(grep -ioE "\"(model|advisorModel)\"[[:space:]]*:[[:space:]]*\"(${TIERS})\"" "$f" 2>/dev/null || true)"
  [ -z "$PAIRS" ] && continue
  while IFS= read -r pair; do
    [ -z "$pair" ] && continue
    KEY="$(printf '%s' "$pair" | grep -ioE '"(model|advisorModel)"' | tr -d '"' | head -1)"
    VAL="$(printf '%s' "$pair" | grep -ioE ":[[:space:]]*\"(${TIERS})\"" | grep -ioE "(${TIERS})" | head -1)"
    # Boundary after VALUE is required (space or EOL), THEN the ADR ref on that line.
    if [ -f "$EXCEPTIONS" ] && grep -iE "^${KEY}=${VAL}([[:space:]]|\$)" "$EXCEPTIONS" 2>/dev/null | grep -q 'ADR-'; then
      continue
    fi
    FAIL=1
    echo "BLOCKED (VibeGates R-1/R-4): bare model tier in $f (${KEY}: ${VAL}) — pin it, or add '${KEY}=${VAL} ADR-XXXX' to .claude/model-exceptions.txt" >&2
  done <<EOF_PAIRS
$PAIRS
EOF_PAIRS
done

# 3) The exceptions file itself: every line must carry an ADR reference.
if [ -f "$EXCEPTIONS" ]; then
  NAKED="$(grep -vE '(^[[:space:]]*$|^#|ADR-)' "$EXCEPTIONS" || true)"
  if [ -n "$NAKED" ]; then
    FAIL=1
    echo "BLOCKED (VibeGates R-23): exception without ADR reference in $EXCEPTIONS:" >&2
    printf '%s\n' "$NAKED" | head -5 >&2
  fi
fi

if [ "$FAIL" -ne 0 ]; then
  echo "A bare tier resolves to whatever the platform decides (measured 2026-08-05). Pin the catalogue identifier." >&2
  exit 2
fi
if [ "$SCANNED" -eq 0 ]; then
  echo "OK (R-1/R-4): nothing in scope — 0 agent/skill/settings files found under $ROOT/.claude (green by absence, not by verification)."
else
  echo "OK (R-1/R-4): no bare model tiers in $SCANNED scanned file(s); exceptions all ADR-referenced."
fi
exit 0
