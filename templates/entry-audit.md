# Entry Audit — [existing project] — YYYY-MM-DD

Purpose: measure the gap between the project's current state and the framework (R-24), at its next work pass. Every gap becomes a procurement request, a documented academic search, or an ADR-planned work item — never a "later" outside the register.

## 1. State per gate
| Gate | Key requirement | Observed state | Gap | Treatment (procurement / search / ADR+work) |
|---|---|---|---|---|
| G0 | Specs + ADRs + threat model + regulatory requirements identified | | | |
| G1 | Provenance of existing generated artifacts | | | |
| G2 | Historical review coverage; checklist in place | | | |
| G3 | SAST, tests, lockfiles, dependency verification | | | |
| G4 | Fitness functions; duplication/churn/refactor baseline recorded | | | |
| G5 | Naked TODOs; SATD; debt register | | | |
| G6 | SBOM; license scan; regulatory plan | | | |
| G7 | Commit rights (single accountable integrator) | | | |

## 2. Stock of unreviewed generated code
[Inventory: volume, affected modules. This stock is inadvertent-reckless debt (Fowler): ADR-planned resorption, security-critical paths first.]

## 3. Initial metric baseline (point zero for the R-15 series)
| Metric | Value at audit date |
|---|---|
| Duplication | |
| Churn < 2 weeks | |
| Refactor/addition ratio | |

## 4. Entry verdict
[Integrator: what blocks immediately (red gates enforceable now) vs what enters the register with a deadline.]
