# ADR-0002 — Pass-2 enforcement additions: model-pinning linter and bounded-batch CI gate

- **Status**: accepted
- **Dates**: decided 2026-08-13 · approved 2026-08-13 · last modified 2026-08-13
- **Decision owner**: the integrator (orchestrator session, Fable 5 pinned)
- **Gate concerned**: G1 (generation control), G2/G7 (batch size at integration)
- **Affected elements**: `enforcement/lint-model-pinning.sh` / `.ps1`, `templates/ci-gates.yml`, `.github/workflows/gates.yml`, rules R-1/R-4/R-25

## Context

The product's measured gap at Pass-2 open: 26 rules, 2 machine-enforced (naked-debt markers, `--no-verify`). Two rules are machine-checkable today with no new dependencies:

1. **R-1/R-4 (pinned identifiers).** Founding incident, measured 2026-08-05: a bare tier `opus` in an agent definition silently resolved to a service variant of a different model than the one policy required — a bare tier resolves to whatever the platform decides at call time. A second occurrence was caught 2026-08-13 in another governed repo (Agent-tool tier enum). The failure mode is silent, recurrent, and textual — i.e., lintable.
2. **R-25 (bounded batch size).** DORA 2024 (pp. 39–40) [read]: "an estimated 7.2 % reduction" in delivery stability "for every 25 % increase in AI adoption" (relative); DORA's stated hypothesis is changelist inflation. The bound belongs at CI, where integration happens.

## Decision

1. **Ship `enforcement/lint-model-pinning.sh` (and a `.ps1` port).** It scans `.claude/agents/**/*.md`, `.claude/skills/**/*.md` frontmatter and `.claude/settings*.json` for bare model tiers (`opus|sonnet|haiku|fable|inherit|default|opusplan`). Exit 2 blocks. **Exemption is visible at point of use**: a bare tier passes only if its own line carries an `ADR-` reference (frontmatter, e.g. `model: fable # ADR-0003`); for JSON (no comments), an exceptions file `.claude/model-exceptions.txt` whose lines must each carry an `ADR-` reference. An undocumented exception is a defect (R-23 applied to model choice).
2. **Add two jobs to `templates/ci-gates.yml`**: `g1-generation-control` (runs the linter) and `r25-batch-size` (fails when the PR's changed lines exceed `VIBEGATES_PR_LIMIT`). The limit ships **fail-closed and unset**: the job fails with instructions until the adopting project sets the variable from its own sourced ADR — a hardcoded default would be a naked number (R-23/P1).
3. **Wire the linter into this repository's own `gates.yml`** (`g1-model-pinning` job), effective immediately — it guards the `.claude/` agent/skill pack planned in this pass.
4. **This repository's own R-25 wiring is deferred** as deliberate-prudent debt (Fowler quadrant): principal = `r25-batch-size` job not yet in `gates.yml`; owner = integrator; due = Pass 3 close; reason = the numeric bound must first be sourced (Pass-2 sweep L3/L7 workers tasked with review-size evidence) — enabling it unsourced would violate R-23, and enabling it mid-pass against the Pass-2 branch would retroactively change the gate under the work, which R-22 forbids in both directions.

## Sources

- DORA / Google Cloud, *Accelerate State of DevOps 2024*, pp. 39–40 [read — page-verified 2026-08-13] (R-25 basis; already in the 02 §4 matrix).
- Internal measurements: bare-tier resolution incidents 2026-08-05 and 2026-08-13 (documented in the maintainer's governance corpus and the Shogen G7 verdict of 2026-08-13).
- Anthropic documentation on agent-definition frontmatter and settings files: mechanism grounding delegated to Pass-2 sweep worker A2. **Condition discharged 2026-08-13**: A2's [read] findings confirm the scanned locations — project `.claude/agents/` is scanned recursively by the platform (our `find`/`-Recurse` matches), skills live at `.claude/skills/<name>/SKILL.md`, `model:` frontmatter accepts full pinned IDs — and add the documented caveat that a frontmatter pin is outranked by `CLAUDE_CODE_SUBAGENT_MODEL` and the per-call parameter, which is why the linter complements and never replaces the first-launch resolution control (R-1).

## Rejected alternatives

- **Central allowlist for frontmatter exemptions**: rejected — moves the justification away from the point of use; the reviewer of the agent file would not see that an exemption exists.
- **Hardcoded default PR-size limit (e.g. 400 lines)**: rejected — a naked number without a source at [read]/[abs] level (P1/R-23). Fail-closed beats plausible.
- **Blocking at commit time instead of CI for R-25**: rejected — batch size is an integration-time property (DORA locates the damage at delivery), and local commits may legitimately be large mid-branch.

## Consequences

Positive: machine-enforced rules on this repository go from two (R-13, R-22) to four (adding R-1 and R-4, both carried by the one linter); R-25 additionally becomes machine-enforceable for adopters via the template, this repo's own wiring being the §Decision-4 debt. The founding incident class becomes structurally impossible to ship silently. Negative: adopters must write one ADR before `r25-batch-size` passes — intended friction. Debt contracted (deliberate-prudent, §Decision 4): own-repo R-25 wiring, owner integrator, due Pass 3.
