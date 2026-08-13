#!/usr/bin/env bash
# VibeGates — acceptance set for check-dependency.sh (R-8, ADR-0006), v2 after
# the U3 G2 review: every fixture asserts the LAYER LABEL in stderr, not only
# the exit code (v1's two "L4" fixtures actually blocked at L1 — the shipped
# denylist names all 404 today, the post-disclosure state; L4 is now exercised
# via a scratch copy with a resolving name). NETWORK-DEPENDENT — run manually
# or on the ci-recheck.yml schedule, never merge-blocking (ADR-0006 §7).
# Live-registry caveat: L2 cases use real squat-adjacent names present on
# 2026-08-13; if a registry removes one it degrades to L1 (still a block).

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
C="$HERE/../check-dependency.sh"
WORK="$(mktemp -d)" || { echo FATAL; exit 1; }
trap 'rm -rf "$WORK"' EXIT
PASS=0; FAIL=0
chk() {  # name want_rc label_regex(- for none) cmd...
  local name="$1" want="$2" lbl="$3"; shift 3
  local out rc; out="$("$@" 2>&1)"; rc=$?
  local ok=1
  [ "$rc" = "$want" ] || ok=0
  if [ "$lbl" != "-" ]; then printf '%s' "$out" | grep -qE "$lbl" || ok=0; fi
  if [ "$ok" = 1 ]; then PASS=$((PASS+1)); echo "[ok] $name"
  else FAIL=$((FAIL+1)); echo "[FAIL] $name (rc=$rc want=$want; label '$lbl')"; fi
}

chk "L1 real pypi passes + L3 warning machine-visible (requests, exit 1)" 1 "WARNING.*L3" bash "$C" pypi requests
chk "L1 real npm passes (express)" 0 "OK \(R-8\)" bash "$C" npm express
chk "L1 hallucinated blocks AT L1" 2 "L1 existence" bash "$C" pypi vibegates-nonexistent-hallucination-xyz9
chk "denylist name blocks (at L1 today - post-disclosure 404 state)" 2 "L1 existence" bash "$C" pypi aws-cdk
chk "denylist scoped npm name blocks (at L1 today)" 2 "L1 existence" bash "$C" npm "@ember/service"
chk "L2 live near-name blocks AT L2 (pypi pips ~ pip)" 2 "L2 proximity.*'pip'" bash "$C" pypi pips
chk "L2 live near-name blocks AT L2 (npm expresss ~ express)" 2 "L2 proximity.*'express'" bash "$C" npm expresss
chk "L2 live near-name blocks AT L2 (pypi panda ~ pandas)" 2 "L2 proximity.*'pandas'" bash "$C" pypi panda
chk "exact popular match passes + L3 warning (pypi pip, exit 1)" 1 "WARNING.*L3" bash "$C" pypi pip
chk "uncovered ecosystem fails closed" 2 "could not run" bash "$C" cargo serde
chk "broken network fails closed" 2 "could not run" env ALL_PROXY=http://127.0.0.1:9 bash "$C" pypi requests
chk "bad charset fails closed (homoglyph route)" 2 "could not run" bash "$C" pypi "evil;rm"

# L4 exercised on a RESOLVING name via scratch copy (the committed names 404 today)
SCR="$WORK/scr"; mkdir -p "$SCR/data"; cp "$C" "$SCR/cd.sh"
printf '# scratch\npypi google-auth\n' > "$SCR/data/slopsquatting-denylist.txt"
cp "$HERE/../data/popular-pypi.txt" "$SCR/data/"; cp "$HERE/../data/popular-npm.txt" "$SCR/data/"
chk "L4 blocks a RESOLVING name AT L4 (scratch google-auth)" 2 "L4 denylist" bash "$SCR/cd.sh" pypi google-auth
chk "L4 PEP503 variant google_auth blocks too" 2 "L4 denylist" bash "$SCR/cd.sh" pypi google_auth
chk "L4 PEP503 variant google.auth blocks too" 2 "L4 denylist" bash "$SCR/cd.sh" pypi google.auth
chk "L4 case variant GOOGLE-AUTH blocks too" 2 "L4 denylist" bash "$SCR/cd.sh" pypi GOOGLE-AUTH

# missing data files fail closed (ADR-0004 parity)
SCR2="$WORK/scr2"; mkdir -p "$SCR2"; cp "$C" "$SCR2/cd.sh"
chk "missing data dir fails closed" 2 "could not run" bash "$SCR2/cd.sh" pypi requests
mkdir -p "$SCR2/data"; cp "$HERE/../data/popular-pypi.txt" "$SCR2/data/"; cp "$HERE/../data/popular-npm.txt" "$SCR2/data/"
chk "missing denylist alone fails closed" 2 "denylist data file" bash "$SCR2/cd.sh" pypi requests

# CRLF data must not break L2/L4 (deliberately CRLF copies — ubuntu-runner class)
SCR3="$WORK/scr3"; mkdir -p "$SCR3/data"; cp "$C" "$SCR3/cd.sh"
sed 's/$/\r/' "$HERE/../data/slopsquatting-denylist.txt" > "$SCR3/data/slopsquatting-denylist.txt"
sed 's/$/\r/' "$HERE/../data/popular-pypi.txt" > "$SCR3/data/popular-pypi.txt"
sed 's/$/\r/' "$HERE/../data/popular-npm.txt" > "$SCR3/data/popular-npm.txt"
chk "CRLF data: exact popular still passes (pip, exit 1 = L3 warning)" 1 "OK \(R-8\)" bash "$SCR3/cd.sh" pypi pip
chk "CRLF data: L2 still fires (pips)" 2 "L2 proximity" bash "$SCR3/cd.sh" pypi pips

# invariant: no name may sit in both the denylist and a popular floor
DENY="$WORK/deny.txt"; POPS="$WORK/pops.txt"
grep -hviE "^[[:space:]]*(#|$)" "$HERE/../data/slopsquatting-denylist.txt" | awk "{print tolower(\$2)}" | sort > "$DENY"
grep -hviE "^[[:space:]]*(#|$)" "$HERE/../data/popular-pypi.txt" "$HERE/../data/popular-npm.txt" | tr "A-Z" "a-z" | sort > "$POPS"
BOTH=$(comm -12 "$DENY" "$POPS" | wc -l)
if [ "$BOTH" = 0 ]; then PASS=$((PASS+1)); echo "[ok] invariant: denylist and popular floors are disjoint"
else FAIL=$((FAIL+1)); echo "[FAIL] invariant: $BOTH name(s) in both lists"; fi

# committed lev arithmetic (kitten/sitting=3, request/requests=1, a/a=0)
LEVOUT=$(awk 'function min3(a,b,c){m=a;if(b<m)m=b;if(c<m)m=c;return m}
function lev(s,t,i,j,n,m,d,cost){n=length(s);m=length(t);if(n==0)return m;if(m==0)return n;
for(i=0;i<=n;i++)d[i,0]=i;for(j=0;j<=m;j++)d[0,j]=j;
for(i=1;i<=n;i++)for(j=1;j<=m;j++){cost=(substr(s,i,1)==substr(t,j,1))?0:1;d[i,j]=min3(d[i-1,j]+1,d[i,j-1]+1,d[i-1,j-1]+cost)}return d[n,m]}
BEGIN{print lev("kitten","sitting") lev("request","requests") lev("a","a")}')
if [ "$LEVOUT" = "310" ]; then PASS=$((PASS+1)); echo "[ok] lev arithmetic committed (3/1/0)"
else FAIL=$((FAIL+1)); echo "[FAIL] lev arithmetic got $LEVOUT"; fi

echo "──────────────────────────────"
echo "r8 fixtures: $PASS ok, $FAIL fail"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
