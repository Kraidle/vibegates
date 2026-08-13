# The VibeGates Framework — principles, gates, rules

**Status**: v1.1 (English edition, 2026-08-13 — adds R-26, consultation before improvisation, traced in §4; v1.0: 2026-08-12).
**Nature**: enforceable. A red gate blocks; there is no "exceptional" passage. Thresholds are per-project parameters set by sourced ADR, but their **existence** and **blocking character** are not parameters.
Every countermeasure below traces to a pathology in [01-pathologies.md](01-pathologies.md); the matrix in §4 keeps that honest.

---

## 1. Principles (P)

**P1 — Measurement, never impressions.** The perception/measurement gap is documented at 39 points [METR 2025]. Any "this saves us time" claim requires a measurement; any number requires a source.

**P2 — Presumption of defect.** Every AI-generated artifact is presumed defective until verified — vulnerable-output rates are stationary at 40–45 % since 2022 [Pearce 2022; Veracode 2025], and confidence does not self-calibrate [Perry 2023]. The burden of proof lies with whoever wants to **integrate** the artifact, never with whoever contests it.

**P3 — Understanding before integration (Willison's criterion).** Code nobody has read, tested and understood does not enter the product. This is the line between assistance and vibe coding; the framework forbids the latter, not the former.

**P4 — Full provenance.** Every artifact carries its origin: model (pinned identifier), version, prompt/context, date, reviewer. Common requirement of NIST SSDF/800-218A, the EU AI Act and CRA — and the precondition of any audit.

**P5 — Zero naked debt.** At every pass close, each unresolved point becomes either a formed procurement request (for an unobtainable document), a documented academic search (for a choice or blocker), or ADR-contracted deliberate-prudent debt with owner and due date. A naked "TODO" is a defect of the pass. Since vibe-coded debt is uncontracted and invisible (01 §4.2), the only management is preventing entry. Normative anchor: ISO/IEC/IEEE 42010:2022 §6.2 requires non-conformances be identified **and explained with rationales** [read].

**P6 — The generator is not the verifier.** The tool that produced an artifact cannot be the authority that validates it (30–37 % correct AI refactorings out of the box; 98 % after an independent validation layer [CodeScene 2024]). Verification is adversarial and independent.

---

## 2. The gates (G0–G7)

### G0 — Framing (before any generation)
Requirements: written intent (spec or minimal PRD); structuring decisions in ADRs ([template](../templates/adr.md), format per Nygard 2011 extended to ISO 42010 §6.10); threat model proportionate to risk; applicable regulatory requirements identified.
Evidence: versioned docs; a component without an attached ADR does not get coded.
Counters: indeterminate architecture (01 §3.3), compliance-by-construction failure (01 §6.2).

### G1 — Controlled generation
Requirements: pinned model identifiers only (a bare tier resolves to whatever the harness decides); context supplied to the generator (conventions, existing code, constraints — generating blind to the codebase produces the duplication of 01 §3.2); provenance entry per artifact ([template](../templates/provenance-log.md)).
Counters: silent drift, non-auditability.

### G2 — Human review, 100 % coverage
Requirements: every diff read and **understood** by a reviewer ≠ generator, against an explicit defect-focused [checklist](../templates/review-checklist.md) covering the catalogued traps (dropped branches, inverted booleans, mistreated `this`, tests-as-false-security-certificate, hallucinated dependencies).
Empirical basis (all [read]): exit-criteria inspections improved quality AND productivity — +23 % coding productivity, 38 % fewer errors than walk-throughs [Fagan 1976]; untooled modern review finds fewer defects than expected and drifts toward knowledge transfer [Bacchelli 2013] — hence the checklist; low review coverage costs up to 2 extra post-release defects per component, low participation up to 5 [McIntosh 2014] — hence 100 %, no sampling. Perry's measured moderator (mistrust + rework → fewer vulnerabilities) confirms reviewer posture is the accessible causal variable.
Declared limit: AI-refactoring defects are "subtle and not obvious to the human eye in inspection" [CodeScene 2024] — **G2 never suffices alone; it is always coupled with G3.**
Anti-metric: review speed is never maximized or celebrated — DORA 2024 warns faster reviews under AI may reflect over-reliance, not rigor. No review-latency target may be held against a reviewer under this framework.

### G3 — Automated verification
Requirements: SAST targeting the CWE families where models fail worst (XSS 13.5 % pass, log injection 12.0 % [Veracode 2025]); tests required for all new code with branch coverage; mutation testing (framework: [Jia 2011] — mutation score as adequacy criterion) or property-based testing on critical modules — passing correctness tests served as a false security certificate in [Perry 2023]; **existence and reputation check of every new dependency before installation** (19.7 % hallucinated, 43 % recurring [Spracklen 2025]); lockfiles mandatory.
Empirical basis of the verification layer: fact-checking raises retained AI refactorings from 37 % to **98 %** correctness [CodeScene 2024] — verification is not overhead; it is the multiplier.

### G4 — Architectural health
Requirements: architectural fitness functions in CI (dependency rules, no cycles) [Ford & Parsons, *Building Evolutionary Architectures*, O'Reilly 2017]; three metrics tracked against ADR-set thresholds, with primary-read baselines as danger references — cloned share of changed lines 8.3 %→12.3 % and blocks +81 % under AI [GitClear]; churn drift; refactor ratio collapse to 3.8 %; an architecture description maintained with the minimal content of **ISO/IEC/IEEE 42010:2022 clause 6** [read]: identification and purpose (6.1), stakeholders and concerns (6.2–6.4, including justified non-conformances), viewpoints and views covering every concern (6.6–6.8), recorded inconsistencies and correspondences (6.9), **essential decisions with rationale, owner, timestamps, affected elements and rejected alternatives** (6.10).
Trend rule: two consecutive passes of metric degradation force a consolidation pass before any new feature — the counter-force Lehman's Law II demands [Lehman 1980].

### G5 — Debt (pass close)
Requirements: SATD scan + human inventory of open points at every close (the scan is necessary, never sufficient: architectural debt is invisible to tools [Kruchten 2012]); strict P5; **naked TODO/FIXME forbidden in integrated code**; debt register kept as an explicit backlog of debt items handled in planning [Kruchten 2012] — the only licit residual: deliberate-prudent debt contracted in writing (Fowler's quadrant) with owner and due date.

### G6 — Compliance
Requirements: SBOM generated and versioned; license scan on all integrated code (copyleft surprise, 01 §6.1); security-update capability planned from design (≥5 years where EU CRA applies); if the product touches a high-risk AI-Act system: demonstrable documentation, logs, human oversight; development cycle aligned with NIST SSDF SP 800-218 + 800-218A.

### G7 — Verdict and integration
Requirements: one accountable integrator reviews all G0–G6 evidence adversarially and renders a written verdict referenced by the commit; **only the integrator commits** — generators never do; any red gate blocks without exception or oral waiver.
Counters: material disengagement (01 §7) — responsibility has a name at every integration.

---

## 3. The rules (R)

**Generation** — R-1: pinned model identifiers only; verify actual resolution after any platform change. R-2: no generation without G0. R-3: generator context includes the relevant existing code. R-4: reasoning effort/verbosity settings are pinned per project, not inherited silently.

**Verification** — R-5: 100 % of generated code reviewed and understood (no sampling). R-6: the generator never validates its own output. R-7: every AI-proposed refactoring is treated as a risk change — full diff review, regression tests, specific attention to dropped branches and inverted logic. R-8: every new dependency is verified on the official registry (existence, age, maintainers, downloads) **before** install; AI-proposed install commands are never run verbatim.

**Traceability** — R-9: provenance journal entry per generated artifact (model, date, context, reviewer, verdict). R-10: every documented figure carries source + verification level ([read]/[abs]/[2nd]); [2nd] is never terminal. R-11: architecture decisions live only in versioned ADRs; an unwritten decision does not exist. R-12: SBOM regenerated per release; lockfiles committed.

**Debt & close** — R-13: naked TODO/FIXME forbidden in integrated code; open points live in the debt register with ADR, owner, deadline — or do not enter. R-14: pass close applies P5, never a workaround. R-15: G4 metrics recorded every pass; two consecutive degradations force a consolidation pass.

**Compliance** — R-16: blocking license scan in CI. R-17: regulatory deadlines are project milestones. R-18: distributed products plan ≥5-year security-update capability where applicable.

**Organization** — R-19: pinned models for all agents; roles separated (generator / reviewer / integrator). R-20: only the integrator commits and triggers pipelines. R-21: every agent output is adversarially checked before consumption. R-22: gates are non-discretionary — no urgency, no "prototype" suspends one; a throwaway prototype lives in a marked branch and **cannot be promoted** without passing G0–G7 from scratch. R-23: per-project thresholds are set by sourced ADR; an unsourced threshold is a defect (P1). R-24: the framework applies to new projects from the first commit and to existing projects via an [entry audit](../templates/entry-audit.md) at their next work pass. R-25: **bounded batch size** — small, single-topic PRs; AI inflates changelists and large changes degrade delivery stability ("an estimated 7.2 % reduction… for every 25 % increase in AI adoption" — relative [DORA 2024, pp. 39–40]); the numeric bound is a project ADR parameter. R-26: **consultation before improvisation** — an agent that is blocked, has failed twice on the same approach, or faces a choice between competing solutions consults a designated read-only advisor (routed through the integrator) instead of improvising a workaround; the advice is counsel, never a verdict — adversarial verification (R-21) and the final verdict stay with the integrator, and the advisor never commits (R-20). An improvised workaround is the agentic variant of vibe coding: miscalibrated confidence [Perry 2023] acting without a validation layer [CodeScene 2024].

---

## 4. Traceability matrix

| Pathology (01) | Key evidence | Gates | Rules |
|---|---|---|---|
| Stationary output insecurity (§2.1) | Pearce 2022; Veracode 2025 | G2, G3 | R-5, R-7 |
| Assisted degradation + overconfidence (§2.2, §7) | Perry 2023 | G2, G7 | R-5, R-6, R-26 |
| Unsafe AI refactoring (§2.3) | CodeScene 2024 | G2, G3 | R-7 |
| Issue survival in the wild (§2.4) | Debt-Boom 2026 [preprint] | G3, G5 | R-13, R-15 |
| Duplication, refactoring collapse (§3.2) | GitClear 2025–2026 | G4 | R-3, R-15 |
| Indeterminate architecture (§3.1, §3.3) | Lehman; Parnas; Foote & Yoder; ISO 42010 | G0, G4 | R-2, R-11, R-23 |
| Uncontracted debt, permanent SATD (§4) | SATD-LLM 2026; Kruchten 2012 | G5 | R-13, R-14, R-15 |
| Productivity illusion (§4.3) | METR 2025 | P1 (transversal) | R-10, R-23 |
| Dependency hallucination (§5.1) | Spracklen 2025 | G3 | R-8, R-12 |
| Missing provenance/SBOM (§5.2) | NIST 2024 | G1, G6 | R-9, R-12 |
| License / copyleft risk (§6.1) | Doe v. GitHub; DeVault 2022 | G6 | R-16 |
| Regulatory non-compliance (§6.2) | EU AI Act; EU CRA | G0, G6 | R-17, R-18 |
| Material disengagement (§7) | Vibe-GLR 2025 | G7 | R-20, R-22 |
| AI-inflated batches, delivery-stability degradation (§8.2) | DORA 2024 | G2, G7 | R-25 |

Every pathology has at least one gate and one rule; every gate and rule traces to at least one sourced pathology. No decorative rules.

## 5. Limits and validity

- G4's numeric baselines come from grey literature (COI named); they are default alarm references, not gospel — each project sets thresholds by sourced ADR (R-23).
- METR 2025 is used solely for the perception/measurement gap (P1), not its productivity figure, which its authors label historical.
- G2/G3/G5 and R-15/R-25 carry quantified empirical bases; **G0 and G6 rest on normative requirements** (NIST, ISO 42010, EU law) whose own effectiveness has no equivalent experimental basis to date — a declared limit, to be filled if the literature permits.
- **Falsifiability**: any future study contradicting a matrix pathology obliges revision of the corresponding rule via ADR. The framework is falsifiable, not dogmatic.
