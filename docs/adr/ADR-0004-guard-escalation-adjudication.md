# ADR-0004 — Guard escalation adjudication: in-contract fail-open found at review round 4

- **Status**: accepted (rendered under the maintainer's procuration of 2026-08-13)
- **Dates**: decided 2026-08-13 · approved 2026-08-13 · last modified 2026-08-13
- **Decision owner**: the integrator (orchestrator, Fable 5 pinned), under maintainer procuration
- **Gate concerned**: G3/G5/G6 (the U2 guards), G7
- **Affected elements**: `enforcement/gate-secrets.sh`, `enforcement/gate-gist.sh`, `enforcement/tests/run-fixtures.sh`, [pass-4-report U2](../passes/pass-4-report.md)

## Context

Pass-4 U2 pre-committed an escalation criterion: *if a review round finds an in-contract fail-open, bash iteration stops and the question goes to an ADR — no silent v5.* Round 4 (run `wf_5634fdb0-788`) found exactly one, ESCALATION-TRIGGERING: `gate-secrets.sh` hardcodes `:(exclude)enforcement/` in both modes while its contract declares no such carve-out (probe: a staged AKIA credential under `enforcement/` returns "OK" silently; the identical file anywhere else blocks). The sibling guard declares the same exclusion; the omission is specific to gate-secrets. The reviewer also diagnosed why three prior rounds missed it: the acceptance set tests what the guard catches, never what it declines to look at.

## Decision (the escalation, honoured and adjudicated)

1. **Root cause is a declaration gap, not a bash-capability limit.** The pre-named alternatives (gitleaks-wrapper dependency; downgrading staged mode to advisory) are REJECTED for this finding: the scan engine did not fail — the contract and the code disagreed on scope. The dependency question would reopen only on an *engine* fail-open (criterion re-armed, unchanged).
2. **Sanctioned changes** (this ADR is their G0): (a) gate-secrets declares the `enforcement/` exclusion in its contract AND announces it at runtime (NOTICE parity with the symlink/gitlink skips — no silent scope removal, ever); (b) the exclude-file escape hatch is bounded per the reviewer's proposal: the file must be **tracked**, blanket pathspecs (`.`, `*`, `./`, `**`) are rejected outright, every applied pathspec emits a NOTICE with the count of files it removes from scope, and the contract states the `ADR-` reference is an attribution marker, not a validated cross-reference; (c) the acceptance set gains a **negative-space meta-fixture** — a credential staged in each directory shape the guards treat specially must either block or produce a NOTICE naming the skip; silence over an unscanned path is itself a failing fixture; (d) the GIST gitlink fixture asserts the NOTICE text (closing the half-pinned clause); (e) the GIST contract names Python docstrings (and %/REM/VB-apostrophe comment styles) as declared residual blind spots.
3. **The staged mode remains blocking** and the CI dedicated-scanner backstop remains the contract — unchanged.

## Sources

Round-4 review record (run `wf_5634fdb0-788`, reproduced probes A/L/H/K); the guards' own contracts; pass-2 register basis for the guards (Sakib 2026 [abs]; TechDebt 2026 [abs]). Process basis for the escalation shape: R-22/R-23/R-26 and the U2 pre-commitment.

## Rejected alternatives

- **gitleaks/trufflehog wrapper as the pre-commit guard**: rejected *for this finding* — adds a dependency to fix a declaration gap; the CI backstop already prescribes the dedicated scanner where it belongs.
- **Staged mode downgraded to advisory**: rejected — the fail-open was in scope declaration, not blocking semantics; weakening the block would trade a fixed defect for a permanent one.
- **Silently patching without this ADR**: rejected — the escalation criterion was public; honouring it is the point.

## Consequences

Positive: no silent scope removal can recur (NOTICE parity + negative-space fixture); the escape hatch can no longer live untracked in a working tree; the criterion proved enforceable. Negative: one more review round before U1+U2 merge. No new debt.
