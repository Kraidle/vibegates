#!/usr/bin/env bash
# VibeGates — acceptance set for gate-secrets.sh and gate-gist.sh (Pass-4 U2).
# This IS the guards' contract made executable (G0/R-23): every declared
# behaviour has a fixture; a G2 finding outside this set is a contract-change
# proposal. Run from anywhere inside the repo. Exit 0 iff all cases conform.
# House rule: a guard is proven by a real blocked action — this harness is the
# committed, third-party-reproducible form of that proof.

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
GS="$HERE/../gate-secrets.sh"
GG="$HERE/../gate-gist.sh"
WORK="$(mktemp -d)" || { echo "FATAL: mktemp -d failed"; exit 1; }
trap 'rm -rf "$WORK"' EXIT
PASS=0; FAIL=0

new_repo() {
  R="$WORK/r$RANDOM$RANDOM"; mkdir -p "$R"; cd "$R"
  git init -q -b main; git config user.email t@t; git config user.name t
  git config core.quotepath true
  echo base > base.txt; git add .; git commit -qm init
}

check() {  # name expected_rc actual_rc [extra_ok]
  local name="$1" want="$2" got="$3" extra="${4:-1}"
  if [ "$got" = "$want" ] && [ "$extra" = "1" ]; then
    PASS=$((PASS+1)); echo "[ok] $name"
  else
    FAIL=$((FAIL+1)); echo "[FAIL] $name (want rc=$want got rc=$got extra=$extra)"
  fi
}

run() { "$@" >/dev/null 2>&1; echo $?; }

### ── gate-secrets ──────────────────────────────────────────────
new_repo
printf 'aws_key = "AKIAIOSFODNN7EXAMPLE99"\n' > s.py; git add s.py
check "SEC staged AKIA blocks" 2 "$(run bash "$GS")"
git reset -q; rm s.py

new_repo
printf 'API_KEY = "ZmFrZWtleWZha2VrZXlmYWtl"\n' > s.py; git add s.py
check "SEC uppercase generic blocks" 2 "$(run bash "$GS")"
git reset -q; rm s.py

new_repo
printf 'akia lowercase is not a key: akiaiosfodnn7example99\n' > s.py; git add s.py
check "SEC vendor prefix stays case-sensitive" 0 "$(run bash "$GS")"

new_repo
printf 'x = 1\n' > ok.py; git add ok.py
check "SEC clean pass" 0 "$(run bash "$GS")"

new_repo  # NUL kill-switch dead: NUL in a text file must NOT disable the scan
printf 'X = "a\000b"\nkey = "AKIAIOSFODNN7EXAMPLE"\n' > cfg.py; git add cfg.py
check "SEC NUL byte cannot disable scan" 2 "$(run bash "$GS")"

new_repo  # UTF-16LE content is matchable
printf 'key = "AKIAIOSFODNN7EXAMPLE"\n' | iconv -f UTF-8 -t UTF-16LE > w.ps1; git add w.ps1
check "SEC UTF-16LE scanned" 2 "$(run bash "$GS")"

new_repo  # redaction: output carries path, never value bytes
printf 'API_KEY = "eeeeeeeeeeeeeeeeee55"\n' > "résumé.py"; git add "résumé.py"
OUT="$(bash "$GS" 2>&1)"; rcod=$?
LEAK=1; printf '%s' "$OUT" | grep -q eeeeeeee && LEAK=0
NAMED=0; printf '%s' "$OUT" | grep -q "REDACTED" && NAMED=1
check "SEC non-ASCII blocks, redacted, named" 2 "$rcod" "$((LEAK * NAMED))"

new_repo  # ++ content: exact attribution, no phantom path
printf '%s\n' '++i;' '++ b/HIJACK.txt' 'API_KEY = "dddddddddddddddd44"' > f.c; git add f.c
OUT="$(bash "$GS" 2>&1)"; rcod=$?
ATTR=0; printf '%s' "$OUT" | grep -q '^f\.c:3:' && ATTR=1
NOHJ=1; printf '%s' "$OUT" | grep -q HIJACK && NOHJ=0
check "SEC ++/hijack exact attribution" 2 "$rcod" "$((ATTR * NOHJ))"

new_repo  # subdirectory invocation scans the whole staged set
mkdir -p sub other; printf 'k = "AKIAIOSFODNN7EXAMPLE99"\n' > other/leak.py
printf 'x=1\n' > sub/fine.py; git add .
cd sub
check "SEC staged from subdir still blocks" 2 "$(run bash "$GS")"
check "SEC --tree from subdir works" 2 "$(run bash "$GS" --tree)"
cd "$R"

new_repo  # submodule/gitlink: skipped with notice, no permanent block
SUB=$(git rev-parse HEAD)
git update-index --add --cacheinfo "160000,$SUB,vendor/mod"
printf 'x=1\n' > t.py; git add t.py
OUT="$(bash "$GS" 2>&1)"; rcod=$?
NOTED=0; printf '%s' "$OUT" | grep -q "skipped non-blob" && NOTED=1
check "SEC gitlink skipped with notice" 0 "$rcod" "$NOTED"

new_repo  # exclusions: invalid pathspec fail-closed; naked line blocked; valid ADR passes
printf 'k = "AKIAIOSFODNN7EXAMPLE99"\n' > l.py; git add l.py
printf '../out  # ADR-0002\n' > .vibegates-secretscan-exclude
check "SEC invalid exclude pathspec fail-closed" 2 "$(run bash "$GS")"
printf 'fx/\n' > .vibegates-secretscan-exclude
check "SEC naked exclude line blocked" 2 "$(run bash "$GS")"
mkdir fx; git mv l.py fx/l.py 2>/dev/null || { mv l.py fx/; git add -A; }
printf 'fx/  # ADR-0004 fixtures\n' > .vibegates-secretscan-exclude; git add -A
check "SEC ADR-referenced exclusion passes" 0 "$(run bash "$GS")"

new_repo  # mktemp failure fail-closed
printf 'k = "AKIAIOSFODNN7EXAMPLE99"\n' > l.py; git add l.py
check "SEC broken TMPDIR fail-closed" 2 "$(TMPDIR=/nonexistent-xyz run bash "$GS")"

new_repo  # truncation announced
{ for i in $(seq 1 12); do printf 'API_KEY = "aaaaaaaaaaaaaaaa%02d"\n' "$i"; done; } > many.py; git add many.py
OUT="$(bash "$GS" 2>&1)"; rcod=$?
MORE=0; printf '%s' "$OUT" | grep -q "more lines not listed" && MORE=1
check "SEC truncation announced" 2 "$rcod" "$MORE"

new_repo  # ADR-0004 negative-space: the carve-out is ANNOUNCED and bounded to guard files + tests/
mkdir -p enforcement/tests enforcementX
printf 'k = "AKIAIOSFODNN7EXAMPLE99"
' > enforcement/tests/fixture.py
printf 'k = "AKIAIOSFODNN7EXAMPLE99"
' > enforcementX/creds.py
git add enforcement/tests/fixture.py
OUT="$(bash "$GS" 2>&1)"; rcod=$?
NOTED=0; printf '%s' "$OUT" | grep -q "excluded per contract" && NOTED=1
check "SEC carve-out announced (negative-space)" 0 "$rcod" "$NOTED"
git add enforcementX/creds.py
check "SEC enforcementX/ NOT excluded (blocks)" 2 "$(run bash "$GS")"

new_repo  # ADR-0004: untracked exclude file = fail-closed
printf 'k = "AKIAIOSFODNN7EXAMPLE99"
' > l.py; git add l.py
printf 'anything/  # ADR-9999
' > .vibegates-secretscan-exclude   # untracked on purpose
check "SEC untracked exclude file fail-closed" 2 "$(run bash "$GS")"

new_repo  # ADR-0004: blanket pathspec rejected even when tracked + ADR-referenced
printf 'k = "AKIAIOSFODNN7EXAMPLE99"
' > l.py
printf '.  # ADR-9999 blanket
' > .vibegates-secretscan-exclude
git add l.py .vibegates-secretscan-exclude
check "SEC blanket pathspec rejected" 2 "$(run bash "$GS")"

new_repo  # ADR-0004: applied exclusion announces its removed-file count
mkdir fx; printf 'k = "AKIAIOSFODNN7EXAMPLE99"
' > fx/l.py
printf 'fx/  # ADR-0004 fixtures
' > .vibegates-secretscan-exclude
git add fx/l.py .vibegates-secretscan-exclude
OUT="$(bash "$GS" 2>&1)"; rcod=$?
CNT=0; printf '%s' "$OUT" | grep -q "removes 1 tracked file" && CNT=1
check "SEC applied exclusion announced with count" 0 "$rcod" "$CNT"

new_repo  # round-5: blanket-EQUIVALENT spellings rejected
printf 'k = "AKIAIOSFODNN7EXAMPLE99"
' > l.py
printf './/  # ADR-9999 sneaky
' > .vibegates-secretscan-exclude
git add l.py .vibegates-secretscan-exclude
check "SEC blanket-equivalent .// rejected" 2 "$(run bash "$GS")"

new_repo  # round-5: unquoted dotenv assignment covered
printf 'API_KEY=ZmFrZWtleWZha2VrZXlmYWtl
' > .env.example; git add .env.example
check "SEC unquoted dotenv blocks" 2 "$(run bash "$GS")"

new_repo  # round-5: the REST of enforcement/ IS scanned (narrowed carve-out)
mkdir -p enforcement/policies
printf 'k = "AKIAIOSFODNN7EXAMPLE99"
' > enforcement/policies/prod.py
git add enforcement/policies/prod.py
check "SEC enforcement/ non-guard files scanned" 2 "$(run bash "$GS")"

### ── gate-gist ─────────────────────────────────────────────────
new_repo
printf '# generated by Claude, not sure if ok\nx=1\n' > g.py; git add g.py
check "GIST leading comment blocks" 2 "$(run bash "$GG")"

new_repo
printf 'const x = 1; // Claude wrote this, not sure\n' > g.js; git add g.js
check "GIST trailing comment blocks" 2 "$(run bash "$GG")"

new_repo
printf '//! copilot generated, not sure this works\n' > a.rs; git add a.rs
check "GIST Rust //! blocks" 2 "$(run bash "$GG")"

new_repo
printf '// Claude generated, don\342\200\231t fully understand\n' > g.js; git add g.js
check "GIST U+2019 apostrophe blocks" 2 "$(run bash "$GG")"

new_repo
printf '# g\303\251n\303\251r\303\251 par IA, \303\240 v\303\251rifier\n' > g.py; git add g.py
check "GIST French a-grave verifier blocks" 2 "$(run bash "$GG")"

new_repo
printf '# code par IA, pas s\303\273r\n' > g.py; git add g.py
check "GIST French pas sur blocks" 2 "$(LC_ALL=C run bash "$GG")"

new_repo
printf '# refactored with Copilot, reviewed line by line\nx=1\n' > g.py; git add g.py
check "GIST AI-ref alone passes" 0 "$(run bash "$GG")"

new_repo
printf '# not sure about the rounding here\nx=1\n' > g.py; git add g.py
check "GIST uncertainty alone passes" 0 "$(run bash "$GG")"

new_repo  # redaction: a credential sharing the GIST line must not leak
printf 'token = "AKIAIOSFODNN7EXAMPLE" // copilot wrote this, not sure it works\n' > x.js; git add x.js
OUT="$(bash "$GG" 2>&1)"; rcod=$?
LEAK=1; printf '%s' "$OUT" | grep -q IOSFODNN7EXAMPLE && LEAK=0
check "GIST output redacted (no credential leak)" 2 "$rcod" "$LEAK"

new_repo  # markdown out of scope, both modes
printf '* Claude Code support is untested here.\n' > n.md; git add n.md
OUT="$(bash "$GG" 2>&1)"; rcod=$?
NOTED=0; printf '%s' "$OUT" | grep -q "excluded per contract" && NOTED=1
check "GIST markdown staged passes WITH exclusion notice" 0 "$rcod" "$NOTED"
git commit -qm md
check "GIST markdown --tree passes" 0 "$(run bash "$GG" --tree)"

new_repo  # UTF-16LE with BOM: GIST comment on line 1 must still block
printf '\357\273\277# generated by Claude, not sure\n' > bom.py; git add bom.py
check "GIST UTF-8 BOM line 1 blocks" 2 "$(run bash "$GG")"
git reset -q; rm bom.py
printf '// copilot wrote this, not sure it works\n' | iconv -f UTF-8 -t UTF-16LE > u16.ps1; git add u16.ps1
check "GIST UTF-16LE blocks" 2 "$(run bash "$GG")"

new_repo  # gitlink skip + subdir behaviour
SUB=$(git rev-parse HEAD)
git update-index --add --cacheinfo "160000,$SUB,vendor/mod"
printf 'x=1\n' > t.py; git add t.py
OUT="$(bash "$GG" 2>&1)"; rcod=$?
NOTED=0; printf '%s' "$OUT" | grep -q "NOTICE" && NOTED=1
check "GIST gitlink skipped WITH notice" 0 "$rcod" "$NOTED"
mkdir -p sub; printf '// Claude, not sure\n' > gg.js; git add gg.js
cd sub
check "GIST staged from subdir blocks" 2 "$(run bash "$GG")"
cd "$R"

echo "──────────────────────────────"
echo "fixtures: $PASS ok, $FAIL fail"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
