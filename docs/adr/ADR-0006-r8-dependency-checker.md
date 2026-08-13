# ADR-0006 — R-8 four-layer dependency checker: design decisions

- **Status**: accepted
- **Dates**: decided 2026-08-13 · approved 2026-08-13 · last modified 2026-08-13
- **Decision owner**: the integrator (orchestrator, Fable 5 pinned)
- **Gate concerned**: G3 (R-8, anti-slopsquatting)
- **Affected elements**: `enforcement/check-dependency.sh`, `enforcement/data/slopsquatting-denylist.txt`, `enforcement/tests/run-fixtures-r8.sh`, `templates/ci-gates.yml` (g3)

## Context

Register evidence (Pass 2/3, all cited at their levels there): frontier-model package-hallucination rates 4.62–6.10 % with a 127-name model-agnostic universal set, 8 of the top-10 hallucinated PyPI names within Levenshtein ≤ 2 of a real package, Python measurably noisier than JavaScript (register wording: Python stricter) [Churilov 2026, read]; a metadata layer moves confusion-detection FP from 80 % → 28 %, deployed thresholds Levenshtein ≤ 2 / ≥ 10× downloads / 5 000-weekly floor, and the LLM component's accuracy DECAYED 0.83 → 0.68 on newer data [ConfuGuard, read]; 13.3 % of confirmed npm confusion attacks turn malicious ≥ 5 days post-release (re-check cadence, already shipped as `ci-recheck.yml`); registry existence checking for LLM-emitted names has NO peer-reviewed tooling evaluation — a genuine literature hole (Pass-2 gap).

## Decision

0bis. **PEP 503 normalization on both sides for pypi** (lowercase, `[-_.]+` → `-`) in L4/L2 — separator variants are the same PyPI project (G2 finding: `google_auth` bypassed a scratch-denylisted `google-auth`); npm compared lowercase-verbatim (no equivalence; policy declared).
1. **Four layers, in blocking order**: L1 existence (registry JSON API; a nonexistent name is a hallucination suspect → BLOCK); L4 denylist (bundled, seeded from Churilov's 10 publicly disclosed universal-hallucination names → BLOCK even if the name now resolves — squat risk); L2 proximity against the bundled per-ecosystem popular floor → BLOCK pending human justification — **length-aware** (≥ 6 chars: distance ≤ 2; 3–5: ≤ 1; shorter: exact-only) with exact-match priority, decided after the integrator's own fixture caught 'pip' blocked via 'six' at distance 2 (short names collide trivially; recorded per ISO 42010 §6.10); L3 cross-ecosystem (name resolves on the *other* ecosystem's registry → WARNING notice, never a block alone — declared signal, not verdict).
2. **Dependencies declared honestly**: `curl` REQUIRED (no curl → fail closed); Levenshtein in pure awk (no python dependency); ecosystems v1 = PyPI + npm only (the two with measured rates), others fail closed with a naming message.
3. **Network semantics fail-closed**: any non-404 curl failure (timeout, DNS, 5xx) BLOCKS — an unverifiable dependency does not install (R-8's whole point). 404 on L1 = the blocking finding itself.
4. **The popular-name lists are bundled data with provenance headers** (top names per ecosystem, floor rationale: ConfuGuard's 5 000-weekly / ≥ 10× thresholds are the deployed parameters; the bundled list is a FLOOR, ADR-extensible per project). Bundled data beats a live popularity API: deterministic, reviewable, no rate limits — accepted staleness, refreshed per pass.
5. **No LLM anywhere in the decision path** (ConfuGuard measured decay 0.83 → 0.68; register rule: an LLM may only ever downgrade severity, and this v1 has no LLM at all).
6. **FP/FN behaviour is DECLARED UNMEASURED** until evaluated against the Churilov artifact (procurement 15, verified-researcher access) — printed in the script contract, per the register's engineering-spec requirement.
7. **Network-dependent acceptance tests live in a separate harness** (`run-fixtures-r8.sh`), run manually or scheduled, NOT wired as a blocking CI job (a registry outage must not block unrelated merges; the offline harness stays the blocking one).

## Rejected alternatives

- **Live popularity API for L2**: rejected — nondeterministic, rate-limited, an availability coupling the guard doctrine forbids.
- **Shipping the full 127-name denylist**: impossible — access-restricted (Zenodo verified-researcher); the 10 public names ship, the rest stays a formed procurement (15).
- **LLM benignity filter (ConfuGuard's)**: rejected for v1 — measured decay, and the register bars LLMs as load-bearing gate classifiers.
- **Blocking on L3 cross-ecosystem alone**: rejected — legitimate same-name packages exist on both registries; alone it is a weak signal (declared as such).

## Consequences

Positive: R-8 moves from prose to a runnable check with measured, cited parameters. Negative: bundled lists age (per-pass refresh duty, noted in the pass template); v1 covers two ecosystems. Debt: none new — the FP/FN measurement is procurement-15-gated and declared.
