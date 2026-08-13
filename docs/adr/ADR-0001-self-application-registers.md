# ADR-0001 — This repository keeps its own ADR register and provenance log

- **Status**: accepted
- **Dates**: decided 2026-08-13 · approved 2026-08-13 · last modified 2026-08-13
- **Decision owner**: the integrator (orchestrator session, Fable 5 pinned)
- **Gate concerned**: G0, G1
- **Affected elements**: `docs/adr/`, `docs/provenance-log.md`, `docs/passes/`, [03-pass-methodology.md §5](../03-pass-methodology.md)

## Context

The framework's pass methodology (§5, self-application) states that the framework applies to itself, and its own templates require an ADR register (G0/R-11) and a provenance log (G1/R-9) in any governed repository. Until Pass 2, this repository shipped those templates without instantiating either — a self-application gap surfaced during the Pass-1 close review (2026-08-13): the R-26 port was committed with no ADR and no provenance entry in the very repo that mandates both.

## Decision

We will keep, in this repository: `docs/adr/` (this register, framework template format), `docs/provenance-log.md` (one entry per PR containing generated content), and `docs/passes/` (one plan and one report per pass). Every future normative change (gate, rule, threshold, enforcement mechanism) lands with its ADR in the same PR.

## Sources

- ISO/IEC/IEEE 42010:2022 §6.10 (decision records as first-class AD elements) [read — via the framework's documented substitution, 03 §3].
- NIST SSDF SP 800-218/218A (provenance for generated artifacts) [read].
- Internal measurement: Pass-1 close review, 2026-08-13 — R-26 port shipped without ADR/provenance entry (defect class: self-application gap).

## Rejected alternatives

- **Keep governance artifacts only in the private corpus**: rejected — self-application is the product's public, falsifiable claim (03 §5); invisible governance is unverifiable governance.
- **ADRs in commit messages only**: rejected — not addressable, not listable, violates R-11 ("an unwritten decision does not exist" applies to decision *records* users can consult).

## Consequences

Positive: every normative change becomes reviewable against its rationale; the repo demonstrates its own doctrine. Negative: PR overhead for small normative changes — accepted, R-25 keeps PRs small anyway. No debt contracted.
