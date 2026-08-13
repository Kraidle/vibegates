# Pass 2 — Report (close)

**Closed**: 2026-08-13 · **Integrator**: orchestrator session (Fable 5, `claude-fable-5`, effort high) · **Plan**: [pass-2-plan.md](pass-2-plan.md)

## What ran

- **S1 Source sweep**: workflow `wf_d7c4b2d0-940`, 11 workers pinned `claude-opus-5` effort high, 11/11 returned, 0 errors, 339 tool calls, ~1.27 M worker tokens. **Resolution control passed before consumption**: 81/81 API messages resolved `claude-opus-5` (R-1; transcript grep, 2026-08-13). 86 source entries; every entry carries [read]/[abs] level and a retrieved identifier; failed retrievals recorded as failures (e.g. OpenReview interstitial, ACM 403s, EUR-Lex empty bodies) rather than silently dropped.
- **S2 Backlog**: [pass-2-backlog.md](pass-2-backlog.md) — adjudicated, ranked by machine-enforceability.
- **S3 Shipped enforcement**: model-pinning linter (`enforcement/lint-model-pinning.sh` + `.ps1`). Live fire, two rounds: round 1 — 8 fixtures (6 bash, 2 pwsh), one edge case (two keys on one JSON line) found, fixed, re-proven; round 2, after the G2 review returned **reject** with two reproduced defects — exception-boundary fail-open (`opusplan` exempting `opus`) and whole-file scanning where the ADR said frontmatter — 11 fixtures (7 bash, 4 pwsh) covering the reviewer's exact cases plus case-insensitivity, empty settings JSON, and the zero-files-in-scope honest message; all conforming. CI: `g1-model-pinning` job on this repo; template gains `g1-generation-control` + `r25-batch-size`, whose fail-closed property was itself proven by 5 local scenarios after the review caught the original `--depth=1` variant failing **open** (shallowed base → empty diff → 0 changed lines). ADR-0002's pre-merge condition (linter file-location assumptions re-verified against worker A2's findings) is discharged and recorded in the ADR.
- **G2 review, two rounds**: context-separated reviewer (`claude-opus-5`, effort high). v1, run `wf_e38c7961-064`: **reject** — 2 blocking, 3 major, 7 minor, each closed by fix + re-fire or documented correction. v2 on the corrected tree, run `wf_1ed46293-3ae`: **accept-with-corrections** — all 12 fixes verified by independent reproduction (17 fixtures per port, r25 job re-run across 8 scratch-repo scenarios); 3 residual findings (ADR-token case divergence between ports; a verdict cell pre-filled before v2 ran — the log's own chronology defect, now recorded in the log; stale fixture counts) closed by the integrator, the parity fix proven by a blocking/passing fixture pair on both ports. Reviewer precision, per the pass's own new rule: v1 12/12, v2 3/3 confirmed real.
- **S4 Self-application**: `docs/adr/` (ADR-0001..0003), `docs/provenance-log.md`, `docs/passes/` instantiated.
- **S5 Lifecycle & agent-organization**: [docs/05-lifecycle.md](../05-lifecycle.md) v0.1 draft — phase map L-1→L10, sourced throughout, declared absences printed instead of invented gates.

## Falsifiability actions triggered (02 §5 — mandatory, scheduled as Pass-3 unit 1)

1. **DORA row split**: throughput reversed in 2025 (not robust — stop citing a penalty); stability negative 2024 AND 2025 (replicated — promote). 2. **Duplication row split**: ecosystem-temporal (GitClear 2026) vs within-project (Mao 2026: AI files less duplicated) — the comparative claim is struck. 3. **Veracode refresh** to the 2026 edition (stationarity holds; per-CWE variance drives G3 weighting). 4. **SATD-LLM row updated in place** (SANER 2026 venue confirmed; do not double-count). These edits touch `docs/01`/`docs/02` and the French corpus (doc 02 matrix) — one unit, evidence pack ready in the backlog.

## Debt register at close (03 §3 — nothing naked)

**Deliberate-prudent debts (ADR-contracted, owner: integrator):**
- D1 — Own-repo `r25-batch-size` wiring; due Pass 3 (ADR-0002 §4; bound must be sourced first).
- D2 — Hooks pack + provenance logger implementation, live-fire tested; due Pass 3 (ADR-0003; covers backlog items 9–10).
- D3 — Falsifiability revisions above, applied to `docs/01`, `docs/02`, **`README.md`** (which still prints the 2024 throughput figure) and the French corpus doc 02 — plus the Tier-2 normative edits that land in the same documents: NIST/SLSA anchoring of G2, the SLSA-versioned G1 provenance ladder, the leaderboard-inadmissibility rule, the 100×-claim ban, the G2 cognitive redesign and the R-21 sharpening; due Pass 3, unit 1.
- D4 — `.claude/` plugin pack build (backlog Tier 3 + item 15; design fixed, incl. evals + runner); due Pass 4.
- D5 — French-corpus mirror of the new CI jobs and linter into the corpus `templates/`; due with D3 (same unit, both languages leave the pass aligned).
- D6 — Commit-guard extensions: secret scan (item 2), GIST detector (item 3), flag-debt gate (item 13), config-as-code rule (item 14), scheduled lockfile re-verification (item 5); due Pass 3.
- D7 — R-8 four-layer registry-check script (item 4), published as an engineering spec with its FP/FN behaviour declared unmeasured until evaluated against the Churilov artifact (procurement 15); due Pass 3.
- D8 — Verification-oracle upgrades: FAIL_TO_PASS witness (item 6), two-oracle G3 (item 7); due Pass 4. Safety monotonicity (item 8) stays P4-scheduled behind exploit-oracle availability, revisited at each pass open.
- D9 — Headless AI-gate template + permission/sandbox template doctrine (items 11–12), including the empirical flag-combination test on a pinned CLI version **before** publication; due Pass 4.
- D10 — **Dated regulatory checkpoint (CRA)**: the G6 template and the pass-report template carry the CRA application dates; template edit due **before 2026-09-11**. *(Pass-3 update: procurement 4 closed — OJ text read; the date list is now FOUR entries incl. Chapter IV 2026-06-11, and the reporting shorthand gains the ≤14-day/1-month final-report deadlines; see [pass-3-adjudications.md](pass-3-adjudications.md).)*

**Formed procurement requests to the maintainer** (full bibliographic identity + attempts in the workers' gap records, `wf_d7c4b2d0-940`):
1. DORA 2025 full PDF (services.google.com — exceeds the 10 MB fetch cap): the delivery-performance chapter; needed for 2025 magnitudes (direction only is published).
2. DORA "ROI of AI-assisted Software Development" 2026 (form-gated): change-failure-rate delta; currently [2nd] via InfoQ, barred from the matrix.
3. LinearB 2026 Benchmarks full report (form-gated): adjudicate the circulating "30–41 % debt increase / 4× maintenance / 1.7× issues per PR" figures — unconfirmed on LinearB's own pages, banned until procured.
4. Regulation (EU) 2024/2847 (CRA) Official Journal text (EUR-Lex returned empty bodies ×5): entry-into-force article, Art. 13, Annex I — mirror text stays [2nd].
5. Fan et al., CHI 2026, DOI 10.1145/3772318.3791176 (ACM 403; CC-BY): Methods for the verification-load index (G4 companion metric).
6. Wang/Pradel/Liu ICSE 2026 camera-ready (settles the 6.2 vs 6.4 pts abstract/body discrepancy — logged, body figure cited meanwhile).
7. OpenAI "Why SWE-bench Verified no longer measures frontier coding capabilities" (HTTP 403): vendor corroboration for the leaderboard-inadmissibility rule.
8. Newman et al., Sigstore, CCS 2022 (ACM 403; CC-BY): the only peer-reviewed anchor for the keyless-signing threat model.
9. Anthropic: transcript JSONL schema documentation (undocumented; determines whether call-level model attribution is ever achievable for G1 — ADR-0003).
10. Maranzano et al., IEEE Software 2005 (paywalled): the only candidate *outcome* evidence for design reviews (700+ reviews at AT&T/Avaya/Lucent).
11. Forsgren/Humble/Kim, *Accelerate* (2018), SEM chapters: primary grounding for any trunk-based/branch-lifetime rule.
12. Kohavi/Tang/Xu, *Trustworthy Online Controlled Experiments* (2020): multi-company experiment success rates to update the 2013 one-third prior.
13. Cemri et al., MAST multi-agent failure taxonomy (identifier unrecovered — supply citation or the G2 failure-mode checklist item is dropped).
14. "Shen & Tamkin 2026" / "Sankaranarayanan 2026" deskilling studies (no identifiers found — confirm existence or the deskilling rule is dropped rather than grounded on blog prose).
15. Churilov universal-hallucination corpus (Zenodo 10.5281/zenodo.19859120, verified-researcher access): full 127-name denylist (10 public names ship meanwhile).
16. Boehm, *Software Engineering Economics* (1981), pp. ~40: the one real dataset behind the cost curve — to state precisely what population it describes.
17. Peer-reviewed venue status watch: arXiv 2605.24298, 2603.00897, 2603.08520, 2510.07189 (load-bearing intervention verdicts, all currently unreviewed).

**Documented research gaps (no source exists — recorded, not owed):** no controlled evidence that a blocking gate changes agent/developer behaviour over time (the framework's core assumption); no downstream-outcome study of AI-generated code (CFR/MTTR/rollback) — named in [05-lifecycle §3](../05-lifecycle.md) as the study our own G1 markers make possible; no independent replication of context-separated review for code; no N-version-voting-for-code evidence (voting stays out); no evidence that role-specialised agents beat a general agent (pack ADR carries it as a design bet); no outcome evidence for user-story quality or design reviews (both gates scoped accordingly).

## G7 verdict

**Pass 2 closes CONFORME.** Sources before work (S1 before S5); every figure in the new documents carries source + level; the falsifiability clause was applied against our own matrix, including striking a claim we liked; enforcement shipped is enforcement proven by live fire; every open point above is a dated debt, a formed procurement, or a named research gap. Delivery by PR with required checks — no direct push.
