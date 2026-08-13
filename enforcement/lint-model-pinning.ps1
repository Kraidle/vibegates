# VibeGates gate G1/R-1/R-4 — model-pinning linter, PowerShell port (ADR-0002).
# Same semantics as lint-model-pinning.sh — see its header for the incident basis,
# scope (frontmatter-only for .md files), exemption boundary rule and residual
# limits. Tier matching is case-insensitive; the ADR- reference token is
# case-SENSITIVE (uppercase convention — 'adr-0003' does not exempt). Exit 2 = block.
# Usage: pwsh -File lint-model-pinning.ps1 [-Root <repo-root>]

param([string]$Root = ".")
$Tiers = 'opus|sonnet|haiku|fable|inherit|default|opusplan'
$ExceptionsPath = Join-Path $Root ".claude/model-exceptions.txt"
$fail = $false
$scanned = 0

function Test-Excepted([string]$key, [string]$val, [string]$exPath) {
  if (-not (Test-Path $exPath)) { return $false }
  # Boundary after VALUE (whitespace or EOL), THEN ADR- on that same line.
  $lines = Select-String -Path $exPath -Pattern "^$key=$val(\s|$)"
  foreach ($l in $lines) { if ($l.Line -cmatch 'ADR-') { return $true } }
  return $false
}

# 1) Frontmatter `model:` in agent/skill definitions — only the leading --- block.
$mdFiles = @()
foreach ($d in @(".claude/agents", ".claude/skills")) {
  $p = Join-Path $Root $d
  if (Test-Path $p) { $mdFiles += Get-ChildItem -Path $p -Recurse -Filter *.md -File }
}
foreach ($f in $mdFiles) {
  $scanned++
  $lines = Get-Content $f.FullName
  if (-not $lines -or $lines[0] -notmatch '^---\s*$') { continue }
  $hits = @()
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^---\s*$') { break }
    if ($lines[$i] -match "^\s*model:\s*[`"']?($Tiers)[`"']?\s*(#.*)?$" -and $lines[$i] -cnotmatch 'ADR-') {
      $hits += "$($i + 1):$($lines[$i])"
    }
  }
  if ($hits.Count -gt 0) {
    $fail = $true
    [Console]::Error.WriteLine("BLOCKED (VibeGates R-1/R-4): bare model tier in $($f.FullName) - pin the exact identifier or annotate the line with its ADR:")
    $hits | Select-Object -First 5 | ForEach-Object { [Console]::Error.WriteLine($_) }
  }
}

# 2) Settings JSON — "model"/"advisorModel" bare-tier values, unless excepted with an ADR ref.
foreach ($name in @("settings.json", "settings.local.json")) {
  $f = Join-Path $Root ".claude/$name"
  if (-not (Test-Path $f)) { continue }
  $scanned++
  $content = Get-Content -Raw $f
  if ([string]::IsNullOrWhiteSpace($content)) { continue }
  $pairs = [regex]::Matches($content, "(?i)`"(model|advisorModel)`"\s*:\s*`"($Tiers)`"")
  foreach ($m in $pairs) {
    $key = $m.Groups[1].Value; $val = $m.Groups[2].Value
    if (Test-Excepted $key $val $ExceptionsPath) { continue }
    $fail = $true
    [Console]::Error.WriteLine("BLOCKED (VibeGates R-1/R-4): bare model tier in $f ($key`: $val) - pin it, or add '$key=$val ADR-XXXX' to .claude/model-exceptions.txt")
  }
}

# 3) The exceptions file itself: every line must carry an ADR reference.
if (Test-Path $ExceptionsPath) {
  $naked = Get-Content $ExceptionsPath | Where-Object { ($_ -notmatch '(^\s*$|^#)') -and ($_ -cnotmatch 'ADR-') }
  if ($naked) {
    $fail = $true
    [Console]::Error.WriteLine("BLOCKED (VibeGates R-23): exception without ADR reference in $ExceptionsPath`:")
    $naked | Select-Object -First 5 | ForEach-Object { [Console]::Error.WriteLine($_) }
  }
}

if ($fail) {
  [Console]::Error.WriteLine("A bare tier resolves to whatever the platform decides (measured 2026-08-05). Pin the catalogue identifier.")
  exit 2
}
if ($scanned -eq 0) {
  Write-Output "OK (R-1/R-4): nothing in scope - 0 agent/skill/settings files found under $Root/.claude (green by absence, not by verification)."
} else {
  Write-Output "OK (R-1/R-4): no bare model tiers in $scanned scanned file(s); exceptions all ADR-referenced."
}
exit 0
