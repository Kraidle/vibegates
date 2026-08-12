# G2 Review Checklist — mandatory for every diff (100 %, no sampling)

Reviewer: ______ (≠ generator, P6) — Date: ______ — PR/commit: ______

Basis: unchecklisted review drifts away from defect detection [Bacchelli 2013, read]. Each box is ticked after actual verification. Review speed is not a target (anti-metric, DORA 2024).

## Understanding (Willison's criterion — P3)
- [ ] I can explain every block of this diff without hopeful hand-waving.
- [ ] The diff's intent matches its attached spec/ADR (G0).

## Catalogued traps of generated code
- [ ] No conditional branch silently dropped or absorbed — check **input validation** in particular [CodeScene 2024].
- [ ] No boolean logic inverted/simplified without a covering test [CodeScene 2024].
- [ ] JS/TS: no function extraction mistreating `this` [CodeScene 2024].
- [ ] Functional correctness is NOT taken as proof of security — passing tests served as a false certificate in [Perry 2023, read].
- [ ] Randomness sources, crypto, file paths/symlinks explicitly checked (dominant measured errors, Perry Q1–Q3).
- [ ] XSS and log injection addressed where applicable — model pass rates 13.5 % and 12.0 % [Veracode 2025, read].

## Dependencies (anti-slopsquatting, R-8)
- [ ] Every new dependency verified on the official registry BEFORE install (existence, age, maintainers) — 19.7 % hallucinated, 43 % recurring [Spracklen 2025, read].
- [ ] Lockfile updated and committed.

## Structure (G4)
- [ ] No duplication of existing code the generator didn't know about (R-3); if duplicated: refactor before merge.
- [ ] Batch size conforms (R-25): one topic per PR; otherwise split.

## Traceability
- [ ] Provenance entry filled (provenance log).
- [ ] No naked TODO/FIXME (R-13).

Verdict: ☐ APPROVED ☐ REJECTED — reason: ______
