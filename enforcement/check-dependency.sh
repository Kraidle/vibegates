#!/usr/bin/env bash
# VibeGates R-8 — four-layer dependency checker, v1 (ADR-0006).
# ── CONTRACT (G0; acceptance set = enforcement/tests/run-fixtures-r8.sh,
#    network-dependent, run manually/scheduled — NOT a blocking CI job;
#    a finding outside this contract is a contract-change proposal) ──
# PURPOSE: check ONE dependency name BEFORE installation (R-8: never run an
#   AI-proposed install command verbatim). Layers, in blocking order:
#   L1 existence — registry JSON API; HTTP 404 = hallucination suspect, BLOCK.
#   L4 denylist — bundled universal-hallucination names (Churilov 2026 public
#      subset), BLOCK even if the name now resolves (post-disclosure
#      registration IS the attack).
#   L2 proximity — pure-awk Levenshtein against the bundled popular floor
#      (ConfuGuard deployed thresholds), length-aware: names ≥ 6 chars use
#      distance ≤ 2, 3–5 chars use ≤ 1, shorter exact-only (short names
#      collide trivially — caught by this script's own fixture on 'pip'/'six');
#      an exact popular match anywhere in the list beats any proximity hit.
#      BLOCK pending human justification.
#   L3 cross-ecosystem — name also resolves on the OTHER registry: WARNING
#      notice only, never a block alone (weak signal, declared).
# COVERED: ecosystems pypi | npm (the two with measured hallucination rates).
# FAIL-CLOSED: missing curl; unknown ecosystem; MISSING/UNREADABLE DATA FILE
#   (an absent list must never silently disable its layer — ADR-0004 parity);
#   any non-404 network failure (timeout, DNS, 5xx) — an unverifiable
#   dependency does not install.
# NORMALIZATION: pypi names are PEP-503-normalized on BOTH sides before L4/L2
#   (lowercase; runs of -_. collapse to '-') — separator variants of a
#   denylisted name are the SAME PyPI project; npm names are compared
#   lowercase-verbatim (no such equivalence; policy declared).
# EXIT CODES: 0 pass · 1 pass-with-L3-warning (machine-visible) · 2 block.
# NETWORK COST, declared: 2 registry calls per invocation (L1 + L3), each
#   --max-time 15; loop callers own their rate limiting. Homoglyph/IDN and
#   non-ASCII spellings are OUT OF SCOPE via the charset guard (fail-closed).
# DECLARED LIMITS: FP/FN behaviour UNMEASURED until evaluated against the
#   Churilov artifact (procurement 15); bundled lists are floors with a
#   per-pass refresh duty; no LLM anywhere in the decision path (ADR-0006);
#   version/dist-tags, maintainer metadata and install scripts are NOT
#   inspected (the CI dedicated scanner and human review carry those).
# Usage: check-dependency.sh <pypi|npm> <package-name>     Exit 2 = block.

set -u
DATA="$(cd "$(dirname "$0")" && pwd)/data"
ECO="${1:-}"; NAME="${2:-}"

fail_closed() { echo "BLOCKED (VibeGates R-8): dependency check could not run — $1. Failing closed: do NOT install." >&2; exit 2; }
block() { echo "BLOCKED (VibeGates R-8, $1): $2" >&2; echo "Do NOT install '$NAME' without a human registry review recorded in the PR (R-8)." >&2; exit 2; }

command -v curl >/dev/null 2>&1 || fail_closed "curl not available"
[ -n "$ECO" ] && [ -n "$NAME" ] || fail_closed "usage: check-dependency.sh <pypi|npm> <name>"
case "$ECO" in pypi|npm) ;; *) fail_closed "ecosystem '$ECO' not covered by the v1 contract (pypi|npm only)";; esac
case "$NAME" in *[!A-Za-z0-9@/._-]*) fail_closed "name contains characters outside the registry charset (homoglyph/IDN out of scope, declared)";; esac
[ -r "$DATA/slopsquatting-denylist.txt" ] || fail_closed "denylist data file missing/unreadable"
[ -r "$DATA/popular-$ECO.txt" ] || fail_closed "popular-floor data file missing/unreadable for $ECO"
if [ "$ECO" = "pypi" ]; then NNAME="$(printf '%s' "$NAME" | tr 'A-Z' 'a-z' | sed -E 's/[-_.]+/-/g')"
else NNAME="$(printf '%s' "$NAME" | tr 'A-Z' 'a-z')"; fi

url_for() {  # $1 eco, $2 name
  case "$1" in
    pypi) printf 'https://pypi.org/pypi/%s/json' "$2" ;;
    npm)  printf 'https://registry.npmjs.org/%s' "$(printf '%s' "$2" | sed 's|/|%2F|g')" ;;
  esac
}

http_code() {  # $1 url → prints HTTP code, or CURLFAIL
  local c
  c="$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$1")" || { printf 'CURLFAIL'; return; }
  printf '%s' "$c"
}

# L1 — existence
CODE="$(http_code "$(url_for "$ECO" "$NAME")")"
case "$CODE" in
  200) EXISTS=1 ;;
  404) block "L1 existence" "'$NAME' does not exist on $ECO — hallucination suspect (frontier rates 4.62–6.10 % [Churilov 2026]). If intentional and brand-new, a human records the justification." ;;
  CURLFAIL) fail_closed "network failure querying $ECO" ;;
  *) fail_closed "unexpected HTTP $CODE from $ECO registry" ;;
esac

# L4 — denylist (blocks even though it exists)
DHIT="$(tr -d '\r' < "$DATA/slopsquatting-denylist.txt" | awk -v eco="$ECO" -v n="$NNAME" '
  /^[[:space:]]*(#|$)/ { next }
  $1==eco { e=tolower($2); if (eco=="pypi") gsub(/[-_.]+/,"-",e); if (e==n) { print "HIT"; exit } }')"
if [ -n "$DHIT" ]; then
  block "L4 denylist" "'$NAME' matches a universal-hallucination denylist entry after normalization (all five 2026 frontier models invent it; post-disclosure registration is the attack surface [Churilov 2026])."
fi

# L2 — proximity (Levenshtein ≤ 2 vs bundled popular floor; exact match passes)
LEV_HIT="$(tr -d '\r' < "$DATA/popular-$ECO.txt" | awk -v target="$NNAME" -v eco="$ECO" '
  function min3(a,b,c){ m=a; if(b<m)m=b; if(c<m)m=c; return m }
  function lev(s,t,   i,j,n,m,d,cost){
    n=length(s); m=length(t)
    if (n==0) return m; if (m==0) return n
    for(i=0;i<=n;i++) d[i,0]=i
    for(j=0;j<=m;j++) d[0,j]=j
    for(i=1;i<=n;i++) for(j=1;j<=m;j++){
      cost = (substr(s,i,1)==substr(t,j,1)) ? 0 : 1
      d[i,j]=min3(d[i-1,j]+1, d[i,j-1]+1, d[i-1,j-1]+cost)
    }
    return d[n,m]
  }
  /^[[:space:]]*(#|$)/ { next }
  { pop=tolower($1); if (eco=="pypi") gsub(/[-_.]+/, "-", pop); tl=target
    if (pop==tl) { exact=1; exit }              # exact beats any proximity hit
    thr = (length(tl)>=6) ? 2 : (length(tl)>=3 ? 1 : 0)   # length-aware (ConfuGuard R7 spirit: short names collide trivially)
    if (thr>0 && hit=="" && lev(tl,pop)<=thr) hit=pop }
  END { if (exact) print "EXACT"; else if (hit!="") print hit }
' 2>/dev/null)"
case "$LEV_HIT" in
  EXACT|'') : ;;
  *) block "L2 proximity" "'$NAME' is within the length-aware Levenshtein threshold of the popular package '$LEV_HIT' (77.7 % of real typosquat pairs sit at distance ≤ 2, median 1 [ConfuGuard §5, read — pass-2 register, backlog item 4]). Resolving is not safe — a squat can resolve." ;;
esac

# L3 — cross-ecosystem (warning only, never a block alone)
OTHER="pypi"; [ "$ECO" = "pypi" ] && OTHER="npm"
OC="$(http_code "$(url_for "$OTHER" "$NAME")")"
L3WARN=0
[ "$OC" = "200" ] && { L3WARN=1; echo "WARNING (VibeGates R-8, L3): '$NAME' also resolves on $OTHER — cross-ecosystem confusion signal (weak alone; recorded for the reviewer)." >&2; }

echo "OK (R-8): '$NAME' exists on $ECO, not denylisted (normalized), no length-aware proximity collision with the bundled popular floor. Reminder: this is the machine floor — the PR still lists and justifies the dependency (R-8), and CI re-checks the lockfile on schedule."
exit $L3WARN
