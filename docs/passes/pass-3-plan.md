# Pass 3 — Plan (G0): procurement intake & falsifiability revisions

**Opened**: 2026-08-13 · **Integrator**: orchestrator (Fable 5, `claude-fable-5`, effort high) · **Workers**: `claude-opus-5`, effort high (resolution control re-checked at first launch of this pass).
**Mid-pass doctrine amendment (maintainer rule, 2026-08-13, recorded here because it changed this pass's own worker roster)**: bibliographic READING is henceforth done by dedicated reader agents pinned **`claude-sonnet-5`, effort xhigh**, advised by a Fable-5 reading-advisor — instituted after the 12-worker intake launched; the two reader dispatches of this pass (DORA 2024 re-read; Maranzano) ran under the new rule, resolution-controlled 22/22 and 4/4 messages `claude-sonnet-5` (transcript grep, 2026-08-13).
**Status**: open.

## Objective

The maintainer has delivered the Pass-2 procurement corpus (~50 primary documents, local files), covering most of the 17 formed requests and substituting several with stronger papers of the maintainer's choosing. This pass: (1) reads each document against the exact question that motivated its request, at [read] level; (2) adjudicates every figure that was [2nd]-barred from the matrix (admit with primary citation, or record as fabrication); (3) applies the D3 falsifiability revisions to `docs/01`/`docs/02`/README with the now-primary magnitudes; (4) D5 corpus mirror. Anthropic-mechanism questions are answered from the live Claude docs (maintainer's standing instruction), never from memory.

## Intake map (document → motivating question)

- **DORA 2025 State of AI-assisted (142 p.) + a file supplied as the 2024 report (48 p. — later identified as the CLUSIF counterfeit; the authentic 120-p. v. 2024.3 was supplied and read the same day)** → procurement 1: 2025 throughput/stability magnitudes; exact 2024 figures re-verified at source.
- **DORA ROI 2026 (60 p.) + AI Capabilities Model (97 p.)** → procurement 2: CFR delta and ROI figures (currently [2nd] via InfoQ, barred); capabilities↔G0–G7 mapping.
- **LinearB 2026 Benchmarks (150 p.)** → procurement 3: adjudicate the circulating "30–41 % debt increase / 4× maintenance / 1.7× issues per PR" — primary or fabrication.
- **CRA — Official Journal L/2024/2847 (81 p.)** → procurement 4: entry-into-force/application article verbatim, Art. 13 hook, Annex I SBOM wording — replaces the [2nd] mirror text.
- **Sigstore CCS'22 (15 p.) + next-gen signing + 2 supply-chain taxonomies + sabbagh2015** → procurement 8: peer-reviewed anchor for the keyless-signing threat model; taxonomy check of R-8/G1 coverage.
- **Kohavi ch. 1 (43 p.) + Accelerate (195 p.)** → procurements 11–12: multi-company experiment success rates; trunk-based/branch-lifetime constructs and their SEM basis.
- **arXiv 2503.13657 (47 p., presumed MAST) + agent-failure set (Exploring Autonomous Agents; 2602.20206; 2601.20245; PerfScout ICSE'26; 2310.08923)** → procurement 13 + maintainer substitutions: identify each, extract failure taxonomies for the G2/G7 checklists and R-21/R-26 grounding.
- **Technical-debt corpus (avgeriou2021, codabux2017, ampatzoglou2018, ramasubbu2015, guo2016, guo2011, sharma2019, alves2016, huijgens2013)** → maintainer substitution: G5's debt taxonomy, measurement and interest models get an academic base beyond Kruchten.
- **Cognitive-load & trust corpus (sweller2018, kaplan2021, galy2017, nygren1991, dewinter2014, rubio2003, chen2011, camuto2021, mckendrick2018, workload-review, trust-SLR, Thinking-Hard)** → substitution for procurement 5 (CHI 2026 blocked): ground the G4 verification-load proxy and G2 trust-calibration design from the underlying literature directly.
- **DORA-metrics validity set (forsgren2017, forsgren2018, thompson2017, baker1997)** → metrics-validity basis for the per-unit delivery-metrics rule.
- **Maranzano 2005 + Clean Architecture (books)** → procurement 10: outcome evidence for design reviews; boundary doctrine cross-check for G4.
- **OpenAI SWE-bench page (URL only)** → procurement 7: fetch attempt from the French locale URL.
- **Anthropic (live docs, dedicated worker)** → procurement 9 (transcript JSONL schema — is call-level model attribution possible?) + the A-worker gaps: agent-teams, settings reference keys (`advisorModel`), env-vars semantics, structured-outputs contract.

## Scope: ships this pass

S1 intake sweep (structured, per-question extraction, doc-03 levels). S2 adjudication table: every barred figure resolved. S3 D3 revisions (docs/01, 02 matrix, README) with primary magnitudes. S4 D5 corpus mirror (French). S5 updated debt register (D-items closed or rolled with cause).

## Out of scope → stays registered

D1 (own-repo R-25 wiring — bound decidable once LinearB/DORA magnitudes admitted; adjudicated in this pass's ADR if the evidence suffices), D2 (hooks pack build), D4 (.claude pack), D6–D9 tooling builds. Clean-Architecture-wide doctrine review (book-scale; only targeted G4 questions this pass).

## Shogen procuration (recorded)

The maintainer declares Shogen's conformity unit done in due form and grants the Fable agents (orchestrator + advisor) procuration to settle any remaining open question academically and documentedly. Standing open items tracked from the 2026-08-13 verdict: the first real `reproductibilite.yml` run at push. Any adjudication under this procuration will be documented with sources in the relevant repo, never improvised.

## Delivery

Branch `pass-3-procurement-intake`, unitary commits, PR with required checks.
