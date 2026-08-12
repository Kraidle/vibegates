# VibeGates gate G7/R-13/R-22 — commit guard (PowerShell, Windows agent harnesses).
# PreToolUse-style hook: receives {"tool_input":{"command":"..."}} on stdin.
# Blocks: (1) git commit --no-verify (R-22); (2) staged diffs introducing naked TODO/FIXME (R-13).
# Exit 2 = block, stderr returned to the agent. Validated 4/4 in direct tests
# (pass-through, no-verify block, non-repo pass, staged-TODO block).
$in = [Console]::In.ReadToEnd()
try { $j = $in | ConvertFrom-Json } catch { exit 0 }
$cmd = $j.tool_input.command
if (-not $cmd) { exit 0 }
if ($cmd -notmatch 'git(\s+\S+)*?\s+commit') { exit 0 }

if ($cmd -match '--no-verify') {
  [Console]::Error.WriteLine('BLOCKED (VibeGates R-22/G7): git commit --no-verify bypasses verification. No exceptions.')
  exit 2
}

$staged = git diff --cached -U0 2>$null
if ($LASTEXITCODE -eq 0 -and $staged) {
  $bad = @($staged | Where-Object { $_ -match '^\+' -and $_ -notmatch '^\+\+\+' -and $_ -match '\b(TODO|FIXME)\b' })
  if ($bad.Count -gt 0) {
    [Console]::Error.WriteLine('BLOCKED (VibeGates R-13): staged diff introduces naked TODO/FIXME:')
    $bad | Select-Object -First 5 | ForEach-Object { [Console]::Error.WriteLine("  $_") }
    [Console]::Error.WriteLine('Handle before commit: debt register + ADR (deliberate-prudent debt), or resolve the point. A naked owed item is a pass defect.')
    exit 2
  }
}
exit 0
