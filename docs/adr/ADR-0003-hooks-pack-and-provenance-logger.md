# ADR-0003 — Hooks pack and provenance auto-logger: design fixed, implementation deferred (due Pass 4)

- **Status**: accepted (design, **amended by the Pass-3 intake** — see Amendment); implementation contracted as deliberate-prudent debt, owner integrator, due Pass 4 close (rolled once, with cause: Pass 3 consumed by procurement intake)
- **Dates**: decided 2026-08-13 · approved 2026-08-13 · last modified 2026-08-13 (amendment same day)
- **Decision owner**: the integrator (orchestrator session, Fable 5 pinned)
- **Gate concerned**: G1, G5, G7
- **Affected elements**: future `enforcement/hooks/`, plugin `hooks/hooks.json`, `templates/`, [backlog items 9–10](../passes/pass-2-backlog.md)

## Context

Pass-2 worker A1 read the Claude Code hooks reference in full (code.claude.com/docs/en/hooks, retrieved 2026-08-13). Decisive findings: the PostToolUse payload enumerates its fields exhaustively and **the model identifier is not among them**, on any per-tool-call event; there is no `$CLAUDE_MODEL`; only SessionStart may receive a `model` field, "not guaranteed to be present". Also established at [read]: exit-2 blocks PreToolUse before permission rules; a timed-out command hook is cancelled and **fails open** ("don't count on a stalled hook to act as a gate"); Stop hooks are overridden after 8 consecutive blocks; hook entries merge across settings levels; repo-level hooks are developer-defeasible via `disableAllHooks` (only managed settings are not); ConfigChange hooks can block settings mutations.

## Decision

1. **The provenance auto-logger is a two-stage join, and claims session-scoped model attribution only.** A SessionStart hook (matcher `*`, covering startup|resume|clear|compact|fork) writes `{session_id → model}` to a sidecar; a PostToolUse async command hook on `Edit|Write|NotebookEdit` appends one record per mutating call (session_id, prompt_id, tool_use_id, cwd, permission_mode, effort, tool_input file path, agent_id/agent_type when present) and joins the model by session_id, recording `model_id_source: seen|absent`. `absent` is a recorded gap, never a silently blank column. Any VibeGates text implying per-call model attribution is corrected: with mid-session `/model` switching, session-scoped is the honest maximum until the transcript-schema procurement (filed in the pass report) is answered.
2. **The commit guard gains an agent-side layer**: PreToolUse on `Bash|PowerShell`, detection by parsing `tool_input.command` (matchers filter on tool name only), exit 2, explicit short `timeout` (fail-fast beats fail-open), plus `permissions.deny` entries for `--no-verify` forms. Honest claim: blocks the direct common form and logs the attempt — shell obfuscation and `core.hooksPath` evasion remain; server-side branch protection stays the authoritative gate.
3. **Enforcement is tiered T1/T2 in all docs**: repo-committed hooks = machine-enforced but developer-defeasible (T1); managed-settings hooks = non-defeasible (T2). Any gate whose bypass is itself the audited event (the commit guard above all) requires T2 for the non-bypassable claim. A ConfigChange hook blocks and logs in-session introduction of `disableAllHooks` or stripping of the VibeGates hook block.
4. **A Stop-hook debt check is shipped as a soft gate only** (8-block override documented), with blocking CI as the backstop — the enforcement claim in all templates is worded accordingly.
5. **Implementation is Pass-3 work** — each hook live-fire tested like the existing guards before merge. Shipping untested hook configs this pass would violate the house rule that a guard is proven by a real blocked action.

## Amendment (2026-08-13, Pass-3 intake, worker W12 — live docs)

The transcript-schema procurement is **answered**: Anthropic states the session-transcript entry format "is internal to Claude Code and changes between versions" (sessions.md; corroborated by agent-sdk/session-storage.md's opaque `SessionStoreEntry`). The rejected alternative "parse the transcript" is therefore rejected *permanently*, by vendor statement. **However, call-level model attribution IS documented via OpenTelemetry**: `claude_code.assistant_response` (and api_request / cost.usage / token.usage events) carry `model` and `requestId` (monitoring-usage, retrieved 2026-08-13). Decision 1 is amended: the logger's model source order becomes **`model_id_source: otel | session | absent`** — OTel telemetry when the project exports it (per-response, strongest), the SessionStart join otherwise, `absent` as a recorded gap. Note the documented interaction, sourced at [read] by Pass-2 worker A1 (hooks reference, common-input-fields `model` row, run `wf_d7c4b2d0-940`): "One set of variables is not inherited: Claude Code removes OTEL_* exporter variables from every subprocess it spawns, including hooks." The OTel route is therefore the harness's own export pipeline, not something a hook reads — the join between the provenance record and OTel events is on `session_id`/timestamps at audit time. Additional intake finding folded in: `CLAUDE_CODE_SUBAGENT_MODEL` overrides even the per-invocation model parameter (env-vars.md) — the CI assertion that it is unset in gate runners is mandatory.

## Sources

Anthropic Claude Code documentation: hooks reference; settings reference [both read, retrieved 2026-08-13 — living unversioned vendor pages; behaviours version-gated (e.g. exit-2+invalid-JSON blocking since v2.1.214), hence a "minimum Claude Code version" field in the templates and re-verification each pass]. Sweep run `wf_d7c4b2d0-940`, worker A1.

## Rejected alternatives

- **Parse the transcript JSONL for per-call model identity**: rejected — schema undocumented, version-fragile; a formed procurement request to Anthropic documentation is filed instead of a workaround (03 §3).
- **PostToolUse-only logger without the SessionStart join**: rejected — produces provenance records with no model field at all, failing P4.
- **Ship hook configs now, test later**: rejected — violates the live-fire house rule; deferral with a dated owner beats an unproven guard.

## Consequences

Positive: G1 gains a machine-generated, honest provenance trail; the R-19/R-20 doctrine (workers never commit) becomes machine-checkable via `agent_id`. Negative: one more pass before the logger exists; session-scoped attribution is weaker than per-call — both stated in the templates. Debt contracted: implementation + live-fire evidence, owner integrator, due Pass 4 close (rolled once from Pass 3, with cause — see Status).
