# VibeGates gate G7/R-13/R-22 — commit guard (PowerShell, Windows agent harnesses).
# PreToolUse-style hook: receives {"tool_input":{"command":"..."},"cwd":"..."} on stdin.
# Blocks: (1) git commit --no-verify (R-22); (2) commits that would introduce naked
# TODO/FIXME (R-13) — staged diff, plus working tree & untracked files when the
# command stages by itself (add / -a / -A), since a PreToolUse hook runs BEFORE
# the command and cannot see a not-yet-executed `git add`.
#
# IMPORTANT (measured, live-tested): when wiring this into a harness that runs the
# command through `pwsh -Command`, append `; exit $LASTEXITCODE` — bare
# `& 'script.ps1'` does NOT propagate the script's exit code, and a blocking
# exit 2 silently degrades to a non-blocking 1.
#   "command": "& 'C:\\path\\gate-commit.ps1'; exit $LASTEXITCODE"
#
# Known residual limit (inherent to pre-execution semantics): content created AND
# committed inside one compound command is invisible at hook time. The CI layer
# (templates/ci-gates.yml, g5 job) is the backstop — defense in depth.
# Exit 2 = block, stderr returned to the agent.
$in = [Console]::In.ReadToEnd()
try { $j = $in | ConvertFrom-Json } catch { exit 0 }
$cmd = $j.tool_input.command
if (-not $cmd) { exit 0 }
if ($cmd -notmatch 'git(\s+\S+)*?\s+commit') { exit 0 }

if ($cmd -match '--no-verify') {
  [Console]::Error.WriteLine('BLOCKED (VibeGates R-22/G7): git commit --no-verify bypasses verification. No exceptions.')
  exit 2
}

# Target directory: cd/Set-Location/git -C in the command, else harness cwd, else current.
$dir = $null
if ($cmd -match '(?:Set-Location|cd)\s+(?:-Path\s+)?["'']?([^"'';|&]+)') { $dir = $Matches[1].Trim() }
elseif ($cmd -match 'git\s+-C\s+["'']?([^"'';|&]+)') { $dir = $Matches[1].Trim() }
elseif ($j.cwd) { $dir = $j.cwd }
$gitArgs = @(); if ($dir -and (Test-Path $dir)) { $gitArgs = @('-C', $dir) }

# Checker files are excluded from their own scan (same convention as the CI g5 job).
$excl = @(':(exclude)enforcement/', ':(exclude).github/')
$lines = @(git @gitArgs diff --cached -U0 -- $excl 2>$null)
if ($cmd -match 'git(\s+\S+)*?\s+add\b' -or $cmd -match '\scommit\s+[^;|&]*(-a\b|-A\b|--all\b)') {
  $lines += @(git @gitArgs diff HEAD -U0 -- $excl 2>$null)
  foreach ($u in @(git @gitArgs ls-files --others --exclude-standard 2>$null)) {
    if ($u -like 'enforcement/*' -or $u -like '.github/*') { continue }
    $p = if ($dir) { Join-Path $dir $u } else { $u }
    if (Test-Path $p) { $lines += @(Get-Content $p -ErrorAction SilentlyContinue | ForEach-Object { "+$_" }) }
  }
}

$bad = @($lines | Where-Object { $_ -match '^\+' -and $_ -notmatch '^\+\+\+' -and $_ -match '\b(TODO|FIXME)\b' })
if ($bad.Count -gt 0) {
  [Console]::Error.WriteLine('BLOCKED (VibeGates R-13): this commit would introduce naked TODO/FIXME:')
  $bad | Select-Object -First 5 | ForEach-Object { [Console]::Error.WriteLine("  $_") }
  [Console]::Error.WriteLine('Handle before commit: debt register + ADR (deliberate-prudent debt), or resolve the point. A naked owed item is a pass defect.')
  exit 2
}
exit 0
