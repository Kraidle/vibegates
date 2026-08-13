#!/usr/bin/env bash
# VibeGates gate G3/G6 — secret scan, v5 (ADR-0004 sanctioned set).
# ── CONTRACT (G0; the acceptance set is enforcement/tests/run-fixtures.sh —
#    a finding outside this contract is a contract-change proposal, R-23) ──
# COVERED: regular blobs (100644/100755) listed by git; staged mode = full
#   staged content of every file touched by the commit (touching adopts
#   content; deletions excluded), --tree = all tracked files; invocation
#   auto-normalizes to the repo root (cwd-independent); content is scanned as
#   BYTES after NUL-stripping — so a NUL byte cannot disable the scan and
#   UTF-16 text is matchable; credential-shaped bytes inside binaries BLOCK
#   (a leak in a binary is still a leak; false positives go through the
#   ADR-referenced exclude file).
# COVERED (added round 5): unquoted env-style assignments KEY=value (dotenv/
#   CI-YAML/Dockerfile shapes — the dominant carrier in the Sakib population).
# OUT OF SCOPE, declared: the guard files themselves (enforcement/gate-*,
#   enforcement/lint-*) and enforcement/tests/ are excluded in BOTH modes
#   (they name their own patterns; announced at runtime by NOTICE; the REST of
#   enforcement/ IS scanned — narrowed per round-5 proposal, ADR-0004); symlinks (120000) and gitlinks/submodules
#   (160000) are SKIPPED WITH A NOTICE, never silently; secrets split across lines;
#   novel token formats; entropy analysis (CI runs a gitleaks/trufflehog-class
#   scanner as the G3 backstop — this guard is the pre-commit floor).
# FAIL-CLOSED on every error path: git errors, unusable exclude pathspecs,
#   mktemp failure, not a work tree.
# OUTPUT REDACTED STRUCTURALLY: the guard never pipes matched content toward
#   its output — only path:line it computed itself; truncation is announced.
# Version history: v1–v4 each rejected by G2 review (ADR-blessed kill-switch;
#   diff-parser fail-opens; grep -I one-NUL kill-switch; undeclared scope
#   removal → escalation, ADR-0004) — see docs/passes/pass-4-report.md U2.
# Basis: hard-coded credentials = 99.6 % of critical-severity agent-PR smells;
#   81.1 % survive review [Sakib et al., KDD-AgenticSE 2026, abs].
# Remedies: real secret → ROTATE (deletion does not unleak); fixture →
#   ADR-referenced pathspec in .vibegates-secretscan-exclude (the ADR- token
#   is an attribution marker, not a validated cross-reference; the file must
#   be TRACKED; blanket pathspecs are rejected; every applied exclusion is
#   announced with its removed-file count — ADR-0004); placeholder →
#   rename it out of credential shape.
# Usage: gate-secrets.sh [--tree]     Exit 2 = block.

set -u
MODE="${1:-}"
EXCL_FILE=".vibegates-secretscan-exclude"

fail_closed() { echo "BLOCKED (VibeGates G3/G6): secret scan could not run — $1. Failing closed." >&2; exit 2; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail_closed "not inside a git work tree"
TOP="$(git rev-parse --show-toplevel 2>/dev/null)" && [ -n "$TOP" ] || fail_closed "cannot resolve repo root"
cd "$TOP" || fail_closed "cannot cd to repo root"

VENDOR='AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{36}|gho_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|xox[baprs]-[0-9A-Za-z-]{10,}|sk-[A-Za-z0-9]{20,}T3BlbkFJ[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9-]{20,}|AIza[0-9A-Za-z_-]{35}|eyJhbGciOi[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]{10,}'
GENERIC='(api[_-]?key|secret|passwd|password|token)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9+/_-]{16,}["'"'"']|(api[_-]?key|secret|passwd|password|token|aws_[a-z_]*key[a-z_]*)=[A-Za-z0-9+/]{16,}'

EXCLUDES=()
if [ -f "$EXCL_FILE" ]; then
  git ls-files --error-unmatch -- "$EXCL_FILE" >/dev/null 2>&1     || fail_closed "$EXCL_FILE exists but is not tracked (an untracked exclusion never reaches review — ADR-0004)"
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    printf '%s' "$line" | grep -q 'ADR-' || {
      echo "BLOCKED (VibeGates R-23): $EXCL_FILE entry without ADR reference: $line" >&2; exit 2; }
    p="${line%% #*}"; p="${p%"${p##*[![:space:]]}"}"
    [ -z "$p" ] && continue
    pn="$(printf '%s' "$p" | sed 's|//*|/|g; s|/$||')"   # normalize: collapse //, strip trailing /
    case "$pn" in .|\*|\*\*|'') fail_closed "blanket exclude pathspec '$p' rejected (ADR-0004)";; esac
    case "$pn" in *..*) fail_closed "parent-traversal exclude pathspec '$p' rejected (ADR-0004)";; esac
    git ls-files -- ":(exclude)$p" >/dev/null 2>&1 || fail_closed "unusable exclude pathspec '$p' in $EXCL_FILE"
    NREM=$(git ls-files -- "$p" 2>/dev/null | wc -l)
    NTOT=$(git ls-files | wc -l)
    [ "$NREM" -ge "$NTOT" ] && [ "$NTOT" -gt 0 ] && fail_closed "exclusion '$p' would remove the ENTIRE scope (ADR-0004)"
    echo "NOTICE (secrets): exclusion '$p' removes $NREM tracked file(s) from scope ($EXCL_FILE)." >&2
    EXCLUDES+=(":(exclude)$p")
  done < "$EXCL_FILE"
fi
echo "NOTICE (secrets): guard files (enforcement/gate-*, lint-*) and enforcement/tests/ excluded per contract (self-match — ADR-0004; the rest of enforcement/ IS scanned)." >&2

TMP="$(mktemp)" && [ -n "$TMP" ] && [ -w "$TMP" ] || fail_closed "mktemp failed"
trap 'rm -f "$TMP"' EXIT

if [ "$MODE" = "--tree" ]; then
  git ls-files -z -- . ':(exclude)enforcement/gate-*' ':(exclude)enforcement/lint-*' ':(exclude)enforcement/tests/' ${EXCLUDES[@]+"${EXCLUDES[@]}"} >"$TMP" 2>/dev/null || fail_closed "git file-list error"
else
  git diff --cached --name-only -z --diff-filter=d -- . ':(exclude)enforcement/gate-*' ':(exclude)enforcement/lint-*' ':(exclude)enforcement/tests/' ${EXCLUDES[@]+"${EXCLUDES[@]}"} >"$TMP" 2>/dev/null || fail_closed "git file-list error"
fi

FOUND=0
while IFS= read -r -d '' f; do
  m="$(git ls-files -s -- "$f" 2>/dev/null | awk '{print $1; exit}')"
  case "$m" in
    120000|160000) echo "NOTICE (secrets): skipped non-blob '$f' (mode $m — out of contract scope)." >&2; continue ;;
  esac
  git show ":$f" >/dev/null 2>&1 || fail_closed "git show failed for '$f'"
  # Bytes after NUL-strip: a NUL cannot disable the scan; UTF-16 becomes matchable.
  LNS="$(git show ":$f" 2>/dev/null | tr -d '\000' | { grep -anE "$VENDOR"; git show ":$f" 2>/dev/null | tr -d '\000' | grep -aniE "$GENERIC"; } | cut -d: -f1 | sort -un || true)"
  if [ -n "$LNS" ]; then
    [ "$FOUND" -eq 0 ] && echo "BLOCKED (VibeGates G3/G6): credential-shaped content detected (output redacted by design — inspect the named lines locally):" >&2
    FOUND=1
    N=$(printf '%s\n' "$LNS" | wc -l)
    printf '%s\n' "$LNS" | head -8 | while IFS= read -r ln; do
      printf '%s:%s: [REDACTED credential-shaped content]\n' "$f" "$ln" >&2
    done
    [ "$N" -gt 8 ] && printf '%s: (+%d more lines not listed)\n' "$f" "$((N-8))" >&2
  fi
done <"$TMP"

if [ "$FOUND" -ne 0 ]; then
  echo "Remedies by class: real secret → ROTATE (deletion does not unleak); fixture → ADR-referenced pathspec in $EXCL_FILE; placeholder → rename it out of credential shape. Basis: 99.6 % of critical agent-PR smells are hard-coded credentials; 81.1 % survive review [Sakib 2026]." >&2
  exit 2
fi
echo "OK (secrets): no credential-shaped content in scope."
exit 0
