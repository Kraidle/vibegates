# Pass Methodology — how work runs under VibeGates

**Status**: v1.0 (English edition, 2026-08-12). Enforceable alongside [02-framework.md](02-framework.md).
A **pass** is any bounded unit of work — research, design, implementation, audit.

## 1. Invariants of every pass

1. **Sources before work.** No design or code before consulting the relevant sources; for research passes, primary sources first.
2. **Verification levels on every cited source**: **[read]** full text or methods/results read · **[abs]** primary abstract read — terminal only if every claim used appears in it · **[2nd]** secondary corroboration — **never terminal**: elevate within the pass or place under a formed procurement request. A naked [2nd] is a defect.
3. **No second-hand numbers.** A figure enters at [read]/[abs], or waits for its procurement. (This framework's own construction caught four wrong figures that way — [01 §1.3](01-pathologies.md).)
4. **Full provenance** for every generated artifact ([template](../templates/provenance-log.md)).
5. **Pinned tools.** Model identifiers pinned; resolution verified after any platform change (R-1/R-4).

## 2. Pass flow

| Step | Content | Gate |
|---|---|---|
| Open | Written objective, scope, sources to consult, ADRs touched | G0 |
| Work | Controlled generation, artifacts traced | G1 |
| Verify | 100 % review + [checklist](../templates/review-checklist.md), CI (G3), metrics (G4) | G2–G4 |
| Close | [Pass report](../templates/pass-report.md), debt section per §3, verdict | G5–G7 |

## 3. Zero-naked-debt close

At close, each unresolved point is **mandatorily** one of:
- **an unobtainable document** → a formed procurement request: full bibliographic identity (DOI/ISBN, pages), dated acquisition attempts, intended use;
- **a choice or blocker** → a documented academic search for solutions, sources attached — never a workaround;
- **deliberate-prudent debt** contracted by ADR with principal, owner, and due date (the only licit residual — Fowler's quadrant).

A naked "owed" item (TODO, "revisit later") means the pass **is not closed**. Normative anchor: ISO/IEC/IEEE 42010:2022 §6.2 — non-conformances shall be identified and explained with rationales.

A legitimate third outcome exists for unobtainable paid standards: **documented academic substitution** — a set of [read] peer-reviewed sources that together cover the intended use, with the residual limit declared and a reopening trigger named. (This framework closed its own ISO/IEC 25010 need that way: verbatim characteristic definitions via IEEE CEIT 2018, model structure via IEEE CIT 2015, measurement via IEEE QRS-C 2016, requirements via AJOR 2013 — with the declared limit that certification-grade use of the 2023 text would require purchase.)

## 4. Entry audit for existing projects

At the next pass of any existing project: audit against G0–G7 with the [entry audit template](../templates/entry-audit.md). Every gap is treated per §3 — no "compliance later" outside the register. The stock of previously unreviewed generated code is inventoried as inadvertent-reckless debt with an ADR-planned resorption path, security-critical paths first.

## 5. Self-application

The framework applies to itself: versioned documents, changelogs, marked sources, counter-evidence section, procurement discipline, falsifiability clause. A rule without a sourced pathology does not enter (02 §4); a contradicting study forces revision (02 §5). Pull requests to this repository are held to the same standard ([CONTRIBUTING](../CONTRIBUTING.md)).
