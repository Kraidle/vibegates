# [Project] — VibeGates rules (assistant instruction extract)

Place this content in your assistant's instruction file: `CLAUDE.md`, `AGENTS.md`,
`.cursorrules`, or `.github/copilot-instructions.md`. Framework: https://github.com/Kraidle/vibegates

## Quality framework (mandatory, non-discretionary)
This repository is governed by VibeGates: **blocking gates G0–G7** and rules R-1..R-26.

Operational consequences in this repository:
1. No code without an attached spec/ADR (G0). ADRs in `docs/adr/` (framework template).
2. Every generated artifact: entry in `docs/provenance-log.md` (G1); 100 % review with the
   G2 checklist by a reviewer who is not the generator (G2).
3. CI per the framework template: blocking jobs, never continue-on-error (G3/G4/G6).
4. Small, single-topic PRs (R-25). Naked TODO/FIXME forbidden (R-13).
5. New dependency: registry check BEFORE install (R-8); never run an AI-proposed
   install command verbatim.
6. Pass close: framework pass report; debt section empty or composed of formed
   procurement requests / documented searches / ADR-contracted debt only (G5).
7. Pinned model identifiers; generator ≠ reviewer ≠ integrator where possible;
   only the accountable integrator commits (R-19/R-20).
8. Existing project? `docs/entry-audit.md` is due at the next work pass (R-24).
9. An agent that is blocked, has failed twice on the same approach, or must choose between
   competing solutions does not improvise a workaround — it files a formed consultation
   request, routed by the integrator to a designated read-only advisor; the advice is
   counsel, the verdict stays with the integrator (R-26).
