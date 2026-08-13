# The Full Lifecycle — from the idea to production and back

**Status**: v0.1 draft (2026-08-13, Pass 2). Extends the framework upstream of G0 and downstream of G7. Rule of construction unchanged (02 §4): a phase enters only where a sourced pathology or a sourced countermeasure exists; where the evidence is absent we say so instead of inventing a gate. Sources were swept and verified 2026-08-13 (Pass-2 sweep, 11 workers, doc-03 levels); levels are marked inline.

## 0. The honest evidence map, first

Three findings reshape how a lifecycle extension may be justified at all:

1. **The cost-of-change curve is not usable.** Boehm & Basili's own 2001 column qualifies the famous 100× to "more like 5:1" for small, non-critical systems [read]; the 1×/6.5×/15×/100× "IBM Systems Sciences Institute" table has no retrievable study behind it; and the largest modern test (Menzies et al., EMSE 2017, 171 projects [read]) finds **no delayed-issue effect** — maximum observed escalation 3.0×, flagship early-vs-late ratio 1.11. Upstream phases below are therefore justified by **irreversibility, blast radius, hit-rate and compliance deadlines** — never by exponential late-fix cost. (Caveat carried: Menzies' population is disciplined-TSP projects; the result may not transfer to undisciplined settings.)
2. **The dominant upstream risk is building the wrong thing, not mis-specifying the right one.** At Microsoft, only about one third of well-designed controlled experiments improved the metric they were built to improve (Kohavi 2009 & KDD 2013 [read], vendor grey). AI-assisted throughput raises the number of ideas shipped — and therefore the absolute number of value-negative changes — unless a value gate exists.
3. **The productivity literature cannot carry weight in either direction.** Cui et al. (Management Science 2026, N=4 867 [abs]) find +26.08 % completed tasks; METR's RCT found −19 %; METR's own follow-up returned intervals straddling zero and was abandoned for selection bias [read]. Gates are grounded on defect-mechanism evidence only; throughput claims are inadmissible in ADRs and waivers, both ways.

## 1. Phase map

```
L-1 idea → L0 discovery/R&D → G0..G7 (build passes, doc 02) → L8 release → L9 operate → L10 market → (loop to L-1)
```

Each phase below states: what enters, the gate artifact, the machine-checkable part, and the evidence status.

### L-1 — Idea (phase zero)

**Gate artifact: the hypothesis record** (ADR family, four required fields): (a) the metric this work is designed to move and its current value; (b) predicted direction and magnitude; (c) how the result will be observed; (d) the kill criterion. Machine-checkable: CI schema check rejects an ADR missing any field — same mechanism as existing ADR checks.
**Why**: the ~one-third experiment hit rate [read, grey]; recording predictions before the build is what lets G7 later render a *value* verdict, not only a code verdict.
**Declared limit**: for products that cannot instrument users, the validation degrades to a documented reasoning artifact — the framework must not pretend a measurement happened. **Declared absence**: no peer-reviewed evidence that Lean-startup/MVP practice reduces waste was found (closest: Fagerholm 2017, a process model with no outcome data); phase zero rests on the hit-rate argument, and says so.

### L0 — Discovery & R&D (requirements, design)

- **AI-assisted artifacts carry provenance upstream, unchanged**: an LLM-drafted spec is an entry-level draft (RE 2024 [abs]) requiring the same G1 record (model, prompt, date, editor) as generated code — reproducibility is the field's #1 reported challenge (66.8 % of 238 studies [abs]).
- **Anti-hallucination traceability**: every requirement statement in an AI-assisted artifact links to a human-supplied source (ticket, transcript, regulation clause) or is explicitly marked a proposal. Machine-checkable as a required field. (Hallucination = 63.4 % reported challenge; the upstream analogue of slopsquatting.)
- **Requirements review = perspective-based reading, not a checklist, not a meeting.** The only controlled-experiment evidence in this space (Porter/Votta/Basili, TSE 1995, replicated [read]): scenario/perspective reading 0.57/0.45 team detection vs checklist 0.41/0.24 (≈ ad hoc); the collection **meeting adds negative net value** (losses 6.8–7.7 % vs gains 3.1–4.7 %). So: each reviewer is assigned one named defect class; individual findings are recorded before any synchronous discussion; the meeting is optional.
- **Story linting** (atomic/minimal/well-formed/uniform/unique — AQUSA, REJ 2016 [read]) is machine-enforceable but **advisory-blocking**: precision is 42–51 % on the hard criteria; block only on the high-precision ones (Unique 100 %, Uniform 87 %). **Declared absence**: no evidence that better user stories reduce downstream defects — the honest justification is ambiguity reduction in the artifact fed to the generator, a G1 argument.
- **Design review is built on omission prompts** ("which quality attribute has no owning mechanism?") at ~2:1 over commission prompts, and does not scope itself to the project's stated goals — the largest ATAM corpus (SEI 2006, 18 evaluations, 99 risk themes [read]) found omissions twice as common as commissions and **no correlation** between stated goals and discovered risks. **Declared absence**: no outcome evidence that design reviews improve delivered systems (descriptive corpus only; Maranzano 2005 procurement filed) — so this review is advisory, scaled to criticality, not blocking.
- **Architecture is the lever that flattens cost, per the same source everyone miscites**: Boehm & Basili attribute curve-flattening to encapsulation confining fixes to small modules — the design-time deliverable that pays is a module boundary decision (feeds G4), not a longer spec.

### G0–G7 — Build passes

Unchanged (doc 02), with the Pass-2 amendments recorded in the backlog: two-oracle G3 with a FAIL_TO_PASS witness; CWE-weighted, ≥2-detector security verification; safety monotonicity across agentic refinement; G2 redesigned around the human-factors evidence (blind-first ordering; AI-hunk labelling in the diff; sanitised review payload; three-level multi-file workflow; review of config and flags as code); R-21 as exactly one context-separated verification pass per artifact version, externally-grounded (tests before LLM review), no vote/debate resolution.

### L8 — Release

- **Change size is the mechanism, not cadence.** Facebook/OANDA (ICSE-C 2016 [read]): critical failures stayed ~constant from 5 000 to 35 000 deploys/month; median deployed change 33 lines. Rule: a deployable change must be small enough to root-cause in isolation — machine-checkable diff ceiling in the pipeline, extending R-25 from review to release. Release engineering is budgeted (the two firms spent ~5 % and ~15 % of engineering on it): mandating gates without funding the machinery gets them bypassed.
- **Rollback is a precondition, not a hope**: an automated, pre-production-exercised rollback path must exist before release — >90 % of severe incidents are mitigated *without* a code change (SoCC 2022, 152 incidents [read]).
- **Canary promotion against pre-committed thresholds**: metric names, baseline, allowed deviation, window — committed to the repo *before* rollout. The measured norm is promotion by dashboard eyeballing (IST 2018, 31 interviews + 187 survey [read]; 63 % use no regression-driven experimentation at all). **Declared absence**: no controlled study quantifying incident *reduction* from canary/progressive delivery was found — the gate is justified on the intuition-vs-threshold argument, and says so.
- **Flags are governed debt** (backlog #13) and **flag state is part of release review** — wrongly-set flags that passed testing are 24.4 % of code-bug incidents [read].

### L9 — Operate

- **"Supervisory engineering work" is a named phase cost** (longitudinal cohort: 82 % report less time writing code; experience degraded 14 %→27 % while perceived productivity stayed at 84 % [abs]) — tracked separately from productivity, which cannot rebut it.
- **The human channel outranks telemetry**: customer feedback detects issues more than monitoring (85 % vs 76 %; 90 % vs 67 % off-Web [read]) — L9 requires a user-report intake with an SLA, not only dashboards.
- **AI systems need AI-specific monitors**: generic monitors miss GenAI failures ~3× more (38.3 % human-detected vs 13.7 % for conventional services; ISSRE 2025 [read]); model-output quality is an availability signal (invalid inference = 14.5 % of severe incidents). Config+infra dominate root causes (51.7 % vs 21.5 % code). Contract: OpenTelemetry `gen_ai.*` conventions, **version-pinned because still `Status: Development`** — an internal rule now, a G6 compliance item only when a stable release exists.
- **Postmortem or it didn't close**: an incident without a complete root-cause+mitigation record is naked debt under G5 (35 % incompleteness measured even at Microsoft [read]). Alerts carry a linked, versioned troubleshooting guide (90.7 % first-attempt triage when they do).
- **AIOps is advisory, never a verdict** — the L9 analogue of R-26: owner-rated correctness of LLM root-cause suggestions averaged 2.4–3.5/5 while readability outscored correctness (ICSE 2023, 44 340 incidents [read]); text-similarity metrics may not gate operational output (correlation with human judgement −0.42 to +0.62).
- **Delivery metrics are per-deployable-unit**: team aggregates are inadmissible for unit health — only 26.8 % of services correlate strongly with their own team's aggregate; one service produced 71.9 % of outages under an acceptable aggregate (ICSSP 2024 [read]). Velocity and stability are read jointly, never singly.

### L10 — Market ("and beyond")

- **Exit condition: the pre-declared OEC moved**, shown by an online controlled experiment or a documented justified equivalent. Default prior: ~2/3 of ideas do not move their target metric [read, grey].
- **A result without a passing data-quality check is inadmissible** — ~6 % of experiments exhibit Sample Ratio Mismatch, which invalidates the readout; the χ² SRM check is a blocking precondition of consuming any experiment result, and an SRM freezes the ship/kill decision until root-caused (KDD 2019 [read]). Concurrent experiments/rollouts are registered in a shared inventory (interference is a named invalidation cause).
- **No post-hoc redefinition of success**: the metric named at L-1 is the metric read at L10; changing it takes a superseding ADR.
- The loop closes: L10 readouts are L-1 inputs for the next cycle.

## 2. The agent-organization layer

Grounded on two legs — Anthropic's documented mechanisms (grey, normative for the tool) and the multi-agent SE literature — with the asymmetry declared: **the negative results are strong and well-venued; the positive evidence that any multi-agent arrangement improves code correctness is thin.** R-21/R-26 are therefore justified as *removing a known failure mode (single-context blindness) at low cost*, not as verified improvement.

- **Roles are structural, not prompted**: the reviewer cannot write (`tools: Read, Grep, Glob`; no `memory` field, which would silently re-enable Write/Edit) [A2, read]. Workers never commit — machine-enforced by a PreToolUse guard denying git commit/push when `agent_id` is present in the hook payload [A1, read].
- **Verification is context-separated**: the reviewer receives the artifact and the ADR spec — not the transcript, not the generator's rationale, not self-assessment comments (judges swing up to ±26 pts on cosmetic cues, EACL 2026 [read]; a subagent inheriting the prompt did no better than self-review [preprint, pending replication]). One pass per artifact version; re-review only after the artifact changes.
- **Disagreement is adjudicated on evidence by one accountable integrator, never by vote or debate** — debate talks correct lone dissenters out of right answers (ICML MAS workshop 2025 [read]); a lone objection closes only with a test, a diff, or a citation.
- **The advisor (R-26) is a consultation channel, not a tribunal**: formed request in, one opinion out, no re-consultation on an unchanged blocker; a blocked worker retrying itself is intrinsic self-correction, which fails (ICLR 2024 [abs]).
- **Pins are declarations, not guarantees**: frontmatter `model:` is outranked by an env var and the per-call parameter, and an org allowlist can substitute silently [A2, read] — hence the linter (shipped) AND the first-launch resolution control AND a SubagentStart provenance hook. Effort precedence is undocumented — empirical check recorded per pass until documented.
- **Instructions are context, not enforcement** — the vendor's own words. Every rule is classified: hook/CI (enforced) or instruction (advisory). Rules that can be machine-enforced must be; the instruction-only residue is listed as accepted risk. Gate-critical text lives only in compaction-surviving locations (project-root CLAUDE.md, hooks); auto-memory is disabled or attached to the provenance journal during graded passes — otherwise it is an unreviewed context source.

## 3. What no phase can claim

The single largest evidential gap, named rather than papered over: **no study measures downstream outcomes (change failure rate, MTTR, rollback rate, experiment success) specifically for AI-generated code.** Every downstream gate above transfers general release/operations evidence to the AI-assisted setting by argument. The framework's own G1 provenance markers make the missing study *possible* — correlating AI-provenance with post-release outcomes is a named research contribution this framework invites, and until it exists, that limit stays printed here.
