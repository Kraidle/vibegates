# Pass 4 — Plan (G0): the build pass

**Opened**: 2026-08-13 · **Integrator**: orchestrator (Fable 5, `claude-fable-5`, effort high) · **Workers**: `claude-opus-5` effort high; readers `claude-sonnet-5` effort xhigh (2026-08-13 doctrine) · Delivery by PR, unitary commits, G2 per unit.

## Objective

Research is settled (Passes 2–3); every tooling debt is dated and its evidence is in the register. This pass builds the machine layer, in register order:

1. **U1 — D10 (calendar-dated, first)**: CRA application dates (OJ-verified) + reporting ladder + ENISA watch item into the G6 surface of `templates/pass-report.md` and `templates/ci-gates.yml`, mirrored to the French corpus. Due before 2026-09-11.
2. **U2 — D6 (guard extensions)**: pre-commit **secret scan** (evidence: 99.6 % of critical-severity agent-PR smells are hard-coded credentials; 81.1 % survive review [Sakib, KDD-AgenticSE'26, abs]) and **GIST detector** (AI-reference + uncertainty marker in one comment = admitted non-comprehension debt [TechDebt'26, abs]) — each live-fire proven; plus template-level: flag-register step, config-as-code paths, scheduled lockfile re-verification (13.3 % of npm confusion attacks turn malicious ≥ 5 days post-release [ConfuGuard, read]).
3. **U3 — D7**: R-8 four-layer registry-check script (engineering spec; FP/FN declared unmeasured).
4. **U4 — D2**: hooks pack + provenance logger per amended ADR-0003 (`model_id_source: otel|session|absent`), live-fired.
5. **U5 — D1**: own-repo R-25 bound, now sourceable (Facebook median 33 changed lines/deploy, Savor ICSE-C'16 [read]) — ADR-0005 sets the bound, job activated on own CI.
6. **U6 — D8/D9/D4**: two-suite oracles, headless gate template (with the empirical flag-combination test), `.claude/` plugin pack + evals.
7. **Transverse**: MAST failure modes → G2/G7 checklist; doc 05 revision with Pass-3 outcomes.

Out of scope: new research (only consuming the register). Shogen watch unchanged.

## Scope discipline

One unit = one PR where practical; U2 guards ship only with live-fire evidence (house rule: a guard is proven by a real blocked action, never by reading it).
