# VibeGates

**An evidence-based, machine-enforced quality-gate framework for AI-assisted development.**

AI coding assistants are extraordinary generators and unreliable engineers. "Vibe coding" — accepting generated code without review, tests, or understanding — ships the gap between the two straight into your product. VibeGates is a set of **eight blocking gates, 26 rules, and a pass methodology** that price verification where it is cheapest, built on two commitments most guidelines skip:

1. **Every rule traces back to a measured pathology** in the peer-reviewed or primary literature (see the [traceability matrix](docs/02-framework.md#4-traceability-matrix)) — and a contradicting study forces a rule revision. Falsifiable, not dogmatic.
2. **The rules are enforced by machinery, not by good intentions**: commit guards that physically reject the violating commit, blocking CI jobs with no `continue-on-error`, and required status checks on the branch. An instruction file is advice; VibeGates ships the mechanisms — because the human factor is itself a measured pathology (assisted developers are *more confident* while writing *less secure* code — ACM CCS 2023).

## The problem, in six primary-source numbers

| Finding | Source |
|---|---|
| **45 %** of AI code-generation tasks produce the vulnerable variant — and security performance is **flat across model generations and sizes**, even as syntactic correctness became near-perfect | Veracode 2025, 80 tasks × 100+ LLMs, SAST-judged ([report](https://www.veracode.com/wp-content/uploads/2025_GenAI_Code_Security_Report_Final.pdf)) [read] [grey: AppSec vendor] |
| Developers with an AI assistant wrote **less secure code on 4 of 5 tasks** — and were **more confident** it was secure. Mistrust + prompt reworking measurably reduced vulnerabilities | Perry, Srivastava, Kumar & Boneh, ACM CCS 2023, n=47 RCT ([DOI](https://dl.acm.org/doi/10.1145/3576915.3623157)) [read] |
| **19.7 %** of packages suggested by 16 LLMs across 576k samples **do not exist**; 43 % of hallucinated names recur across repeated queries — a predictable supply-chain attack surface ("slopsquatting") | Spracklen et al., USENIX Security 2025 ([arXiv:2406.10279](https://arxiv.org/abs/2406.10279)) [read] |
| Refactored/moved code collapsed from **~25 % of changed lines (2021) to 3.8 % (2026)**; duplicated blocks **+81 %** (2023–2026) | GitClear 2025 & 2026 reports, 211M + 623M changed lines ([2025](https://www.gitclear.com/ai_assistant_code_quality_2025_research), [2026](https://www.gitclear.com/the_ai_code_quality_maintainability_gap)) [read] [grey: analytics vendor] |
| Every 25-point increase in AI adoption is associated with **−7.2 % delivery stability** and −1.5 % throughput; product performance shows **no benefit** (+0.2 %, n.s.). DORA's own hypothesis: AI inflates changelist size, and large changes destabilize delivery | DORA / Google Cloud, *Accelerate State of DevOps 2024*, pp. 38–43 ([PDF](https://dora.dev/research/2024/dora-report/2024-dora-accelerate-state-of-devops-report.pdf)) [read] [grey — COI runs *against* the negative finding] |
| Experienced OSS developers were **19 % slower** with AI tools on their own mature repositories — while estimating they had been 20 % faster. A 39-point perception gap | METR 2025 RCT, 16 devs × 246 tasks ([arXiv:2507.09089](https://arxiv.org/abs/2507.09089)) [abs] |

**And the counter-evidence that shapes the framework** (we document what cuts against us — see [Pathologies §8](docs/01-pathologies.md#8-counter-evidence-and-discussion)): AI is genuinely fast where context is thin — +55.8 % on a green-field task (Peng et al. 2023 [abs]) — and **verification is the multiplier**: a fact-checking layer that rejects unvalidated AI refactorings raises their correctness from 37 % to **98 %** (CodeScene 2024 [read]). VibeGates does not ban the tool. It prices the verification.

## The eight gates

| Gate | Name | Blocks until |
|---|---|---|
| **G0** | Framing | A spec and an Architecture Decision Record (ADR) exist for the work; regulatory requirements identified |
| **G1** | Controlled generation | Model identity pinned; context supplied; provenance recorded per artifact |
| **G2** | Human review — 100 % | Every diff read and **understood** by a reviewer who is not the generator, against a defect-focused checklist |
| **G3** | Automated verification | SAST, tests with branch coverage, mutation/property-based testing on critical modules, dependency existence checks, lockfiles |
| **G4** | Architectural health | Fitness functions; duplication / churn / refactor-ratio tracked against ADR-set thresholds; architecture description per ISO/IEC/IEEE 42010 clause 6 |
| **G5** | Debt | Zero naked debt at pass close: every open item becomes a formed procurement request, a documented academic search, or an ADR-contracted deliberate-prudent debt with owner and due date |
| **G6** | Compliance | SBOM, license scan, security-update capability, regulatory checklists (e.g. EU CRA/AI Act where applicable) |
| **G7** | Verdict | A single accountable integrator reviews all gate evidence adversarially and alone commits |

Gates are **non-discretionary**: no urgency, no "it's just a prototype" suspends one (a throwaway prototype lives in a marked branch and cannot be promoted without passing G0–G7 from scratch). Full rules R-1..R-26 and the pathology↔countermeasure traceability matrix: [docs/02-framework.md](docs/02-framework.md).

## Enforced by machines, not vibes

Three layers, by design (details: [adoption profiles](docs/04-adoption-profiles.md)):

| Layer | What it does | Ships as |
|---|---|---|
| **Machine** — blocks | Rejects `git commit --no-verify` and commits introducing naked TODO/FIXME *before they execute*; CI jobs fail the PR on SAST findings, unjustified dependencies, license violations, committed PDFs; branch protection makes the checks required | [commit guards](enforcement/) (live-fire tested — see their headers for the exit-code trap we caught), [blocking CI](templates/ci-gates.yml) |
| **Instruction** — steers | Puts the rules in front of every AI assistant session | [PROJECT-RULES.md](templates/PROJECT-RULES.md) for `CLAUDE.md` / `AGENTS.md` / `.cursorrules` |
| **Process** — makes gaps visible | Review checklists, provenance log, pass reports, entry audits: what can't be automated becomes checkable and attributable | [templates](templates/) |

Declared limit (we measure, we don't oversell): no tooling can enforce *understanding* (P3) or review quality — those remain human obligations made checkable, not automatic. What the machine layer guarantees is that skipping them leaves a visible, attributable trace instead of a silent pass. **This repository runs its own gates**: [blocking workflow](.github/workflows/gates.yml) + required checks on `main`.

## Quick start

1. Read [docs/01-pathologies.md](docs/01-pathologies.md) — why each gate exists, with sources.
2. Adopt the gates: [docs/02-framework.md](docs/02-framework.md) and the [templates](templates/) (ADR, review checklist, provenance log, pass report, entry audit, CI).
3. Wire the enforcement: [enforcement/](enforcement/) ships commit-blocking hooks (naked TODO/FIXME, `--no-verify`), and [templates/ci-gates.yml](templates/ci-gates.yml) the blocking CI skeleton.
4. Tool-specific wiring (Claude Code, Cursor, plain git + CI): [docs/04-adoption-profiles.md](docs/04-adoption-profiles.md).
5. Run an [entry audit](templates/entry-audit.md) on each existing project; new projects apply the gates from the first commit.

## Method: how this framework keeps itself honest

- **Every figure carries its source and a verification level**: `[read]` full text (or methods/results) read · `[abs]` primary abstract read, acceptable only if every mobilized claim appears in it · `[2nd]` secondary corroboration — **never terminal**: it must be elevated or placed under a formed procurement request. A naked `[2nd]` is a defect of the document.
- **No second-hand numbers.** Reading primary sources corrected four figures that secondary summaries got wrong during this framework's own construction — the corrections are documented in place ([docs/01-pathologies.md §1.3](docs/01-pathologies.md)).
- **Preprints are flagged** `[preprint]`; industry reports are flagged `[grey]` with their conflict of interest named.
- **Counter-evidence gets its own section**, built by searching for results that contradict us.
- **Zero naked debt**: this repo closes its own open points the way it asks yours to.

## Governance

The framework is **falsifiable by construction**: every rule in [the traceability matrix](docs/02-framework.md#4-traceability-matrix) rests on at least one sourced pathology, and any future study contradicting a pathology obliges a revision of the corresponding rule through an ADR. Rules without a sourced pathology are not accepted — including in pull requests. See [CONTRIBUTING.md](CONTRIBUTING.md): **this repository applies its own gates to contributions.**

## License

Dual-licensed: documentation (`README.md`, `docs/`) under **CC BY-SA 4.0**; code and templates (`templates/`, `enforcement/`) under **MIT**. See [LICENSE](LICENSE).

## Citing

See [CITATION.cff](CITATION.cff). If VibeGates saved your codebase from a hallucinated dependency, a silent branch deletion, or a 3 a.m. copyleft surprise — cite the underlying studies too. They did the measuring.
