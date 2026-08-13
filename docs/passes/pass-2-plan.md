# Pass 2 — Plan (G0): full-lifecycle alignment & machine enforcement

**Opened**: 2026-08-13 · **Integrator**: orchestrator (Fable 5, pinned `claude-fable-5`, effort high) · **Workers**: `claude-opus-5`, effort high — resolution control due at first workflow launch of this session (R-1).
**Status**: open.

## Objective

Push VibeGates from a commit-time gate framework to the strongest defensible position the current literature and the Anthropic platform documentation allow, along two axes set by the maintainer (2026-08-13):

1. **Full lifecycle** — from phase zero (the idea) through R&D, design, build, release, go-to-market and operations ("and beyond"): identify which lifecycle phases have *evidence-based* gates in the literature, and extend the framework only where a sourced pathology or a sourced countermeasure exists (02 §4 unchanged: no decorative rules).
2. **Agent organization** — specialized agents with skills, advisor/consultation patterns (R-26), role separation (P6): ground an agent-organization layer in Anthropic's documented mechanisms (subagents, skills, hooks, settings) and in the multi-agent SE literature.

Maintainer's constraint: **ultra-useful in practice, not only in theory** — the pass must ship running enforcement, not only prose.

## Scope of this pass (ships)

- **S1 — Source sweep** (11 workers, doc-03 discipline): 4 on Anthropic platform documentation (mechanisms — grey literature, grounds *how*), 7 on academic/primary literature (grounds *why*: pathologies and rules). Every source labeled [read]/[abs]/[2nd]; naked [2nd] is a defect; existence verified before citation.
- **S2 — Traced backlog**: every improvement candidate carries its source and its enforceability class (machine / instruction / process). Ranked by machine-enforceability first (the product's measured gap: 26 rules, 2 enforced).
- **S3 — Shipped enforcement** (at least one, live-fire tested like the existing guards):
  - model-pinning linter (R-1/R-4) over `.claude/agents/*.md` frontmatter and settings files;
  - PR-size gate for CI (R-25, DORA 2024);
  - provenance auto-logger via PostToolUse hook (G1) — conditional on the hook payload confirming feasibility (A1 worker), else registered per 03 §3.
- **S4 — Self-application scaffolding**: this repo gains `docs/adr/` and `docs/provenance-log.md` (instantiated from its own templates), plus this plan and a pass report at close.
- **S5 — Lifecycle & agent-organization architecture draft**: a new document mapping lifecycle phases to gates/roles/skills **only where sourced**, with explicit "no evidence found" declarations elsewhere (falsifiability over coverage).

## Out of scope → registered (03 §3, zero naked debt)

- Full rewrite of docs/01 pathologies (only deltas from S1 enter now); remainder → ADR-contracted with due date at close.
- Corpus (French) back-port of every normative delta: **deliverable of this pass at close** — English (vibegates) is authored first for product tooling; the corpus remains source of truth for the French governance docs. Divergences at close are defects.
- GTM/business-phase gates beyond what sourced evidence supports (e.g., online controlled experiments literature) — anything unsourced is declared, not invented.

## Sources to consult (planned; workers verify existence before citing)

Anthropic: Claude Code hooks reference; subagents; skills; settings/permissions; headless/CI; Agent SDK; agentic-coding best practices; security model. Literature themes: AI codegen security (2024–2026 updates); agentic SE evaluation & multi-agent verification; human factors (overconfidence, review efficacy); technical debt/SATD & longitudinal code quality (incl. DORA 2025 *existence check*); software supply chain & provenance (SLSA, NIST SSDF); upstream economics (requirements defects, discovery); downstream evidence (release engineering, online experimentation).

## ADRs touched

- ADR-0001 (new): this repository keeps its own ADR register (self-application).
- ADR-0002 (new): enforcement additions of S3 (per-tool decisions inside).
- Further ADRs as S2 backlog items are adjudicated.

## Delivery

Branch `pass-2-enforcement-alignment`, single-topic commits, PR to `main` with the 2 required status checks — no direct push (pass-1 lesson, 2026-08-13).
