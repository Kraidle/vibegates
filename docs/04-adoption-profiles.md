# Adoption Profiles — wiring VibeGates into real tooling

**Status**: v1.0. The gates are tool-agnostic; this document maps them onto common setups. Everything here composes: instruction layer (the assistant reads the rules) + machine layer (hooks and CI physically block) + process layer (templates make gaps visible).

## Profile A — any tool, plain git + CI (the portable core)

1. Drop [`templates/PROJECT-RULES.md`](../templates/PROJECT-RULES.md) into the repo root and reference it from your assistant's instruction file (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `.github/copilot-instructions.md` — same content, different filename).
2. Install the commit hook: [`enforcement/gate-commit.sh`](../enforcement/gate-commit.sh) as `.git/hooks/pre-commit` (or via pre-commit/husky). Blocks naked TODO/FIXME in staged diffs. Note `--no-verify` bypasses client-side hooks by design — which is why the CI layer below re-checks, and why agent-harness hooks (Profile B) can block the flag itself.
3. Instantiate [`templates/ci-gates.yml`](../templates/ci-gates.yml): blocking jobs for G3 (tests, SAST, lockfile, new-dependency justification), G4 (fitness functions, duplication), G5 (naked-TODO grep), G6 (SBOM, license scan). **No `continue-on-error`. Ever.**
4. Copy the [ADR](../templates/adr.md), [review checklist](../templates/review-checklist.md), [provenance log](../templates/provenance-log.md), [pass report](../templates/pass-report.md) templates into `docs/`.
5. Existing project? Start with the [entry audit](../templates/entry-audit.md).

## Profile B — Claude Code

- Instruction layer: put the `PROJECT-RULES.md` content in the repo's `CLAUDE.md`; add a pointer in `~/.claude/CLAUDE.md` to apply it across projects.
- Machine layer: a `PreToolUse` hook on `Bash|PowerShell` runs [`enforcement/gate-commit.ps1`](../enforcement/gate-commit.ps1) (or the `.sh`) before any shell command executes — this blocks `git commit --no-verify` itself, which plain git hooks cannot. **Windows/pwsh caveat (measured live)**: when the hook command runs through `pwsh -Command`, a bare `& 'script.ps1'` does not propagate the script's exit code — the blocking exit 2 silently degrades to a non-blocking 1 and the guard fires blanks. Append `; exit $LASTEXITCODE` to the hook command. Then prove the hook fires with a real blocked commit before trusting it — ours didn't on the first wiring, and only a live-fire test caught it. Example `~/.claude/settings.json` fragment:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash|PowerShell",
      "hooks": [{ "type": "command", "command": "bash /path/to/enforcement/gate-commit.sh", "timeout": 30 }]
    }]
  }
}
```

- Role separation (P6/G7): generate with subagents, review and commit only from the main session; pin subagent model identifiers explicitly — a bare tier resolves to whatever the platform decides (R-1).

## Profile C — Cursor / Copilot-style IDE assistants

- Instruction layer: `.cursorrules` / `.github/copilot-instructions.md` carrying `PROJECT-RULES.md`.
- The IDE cannot block; enforcement lives entirely in the git hook + CI from Profile A. Treat inline completions under the same P2 presumption: **the tab key is an integration decision.**
- Dependency guard (R-8): never accept an install command from chat verbatim; check the registry first (existence, age, maintainers). 19.7 % of suggested packages do not exist, and 43 % of the fakes recur predictably [Spracklen 2025].

## Profile D — CI-only minimum (inherited codebases, mixed teams)

If you can change nothing else, instantiate `ci-gates.yml` + branch protection requiring the checks, and bound PR size (R-25). This is the smallest deployment that converts the framework from advice into physics: DORA 2024 locates the AI-era damage at integration (batch size → delivery stability), which is exactly where CI sits.

## What no profile can do

No tooling enforces P3 (understanding) or the quality of a review — those remain human obligations made *checkable* (checklist, provenance, verdict trail) rather than *automatic*. A team that signs checklists without reading diffs has left the framework, whatever the CI says. The framework makes that departure visible and attributable; it cannot make it impossible.
