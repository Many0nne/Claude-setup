# Hook Stop : avant de rendre la main, verifie les fichiers de code modifies par Claude dans cette session.
#   1. ruff check + format --check (Python) et ESLint (TS/Vue/JS), par depot ;
#   2. des tests (ou un type-check) ont ete relances apres la derniere modification de code.
# Exit 2 = Claude reprend la main avec le message. Une seule relance par tour (stop_hook_active) : il peut justifier et s'arreter.

$ErrorActionPreference = 'SilentlyContinue'

$payload = $null
try { $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json } catch { exit 0 }
if (-not $payload -or $payload.stop_hook_active) { exit 0 }
$transcript = [string]$payload.transcript_path
if (-not $transcript -or -not (Test-Path $transcript)) { exit 0 }

. "$PSScriptRoot\lib-lint.ps1"

$codeExt = '\.(py|ts|tsx|vue|js|mjs|cjs)$'
$testCmd = 'manage\.py\s+test|pytest|vitest|\b(yarn|npm|pnpm)\s+(run\s+)?(test|type-check)\b|vue-tsc'

# Cette methode permet de relever, dans l'ordre du transcript, les fichiers de code edites et les commandes de test lancees
# lorsqu'on doit savoir si la derniere modification a ete suivie d'une validation.
function Read-SessionEvents([string]$Path) {
  $events = [System.Collections.Generic.List[object]]::new()
  foreach ($line in [System.IO.File]::ReadLines($Path)) {
    if ($line -notmatch '"tool_use"') { continue }
    try { $o = $line | ConvertFrom-Json } catch { continue }
    foreach ($c in @($o.message.content)) {
      if ($c.type -ne 'tool_use') { continue }
      if ($c.name -in 'Edit', 'Write', 'MultiEdit' -and $c.input.file_path -match $codeExt) {
        $events.Add([pscustomobject]@{ Kind = 'edit'; Value = [string]$c.input.file_path })
      } elseif ($c.name -in 'Bash', 'PowerShell' -and $c.input.command -match $testCmd) {
        $events.Add([pscustomobject]@{ Kind = 'test'; Value = [string]$c.input.command })
      }
    }
  }
  return $events
}

$events = Read-SessionEvents $transcript
$edits = @($events | Where-Object Kind -eq 'edit')
if (-not $edits) { exit 0 }

$messages = @()

# 1. Lint par depot, sur les seuls fichiers touches par Claude et encore presents.
$files = $edits.Value | Select-Object -Unique | Where-Object { Test-Path $_ }
$byRepo = $files | Group-Object { Get-RepoRoot $_ } | Where-Object Name
foreach ($group in $byRepo) {
  $py = @($group.Group | Where-Object { $_ -match '\.py$' })
  $js = @($group.Group | Where-Object { $_ -match '\.(ts|tsx|vue|js|mjs|cjs)$' })
  if ($py) { $r = Invoke-Ruff $group.Name $py -Format; if ($r) { $messages += "ruff ($($group.Name)) :`n$r" } }
  if ($js) { $r = Invoke-Eslint $group.Name $js; if ($r) { $messages += "ESLint ($($group.Name)) :`n$r" } }
}

# 2. Tests relances apres la derniere modification de code ?
$lastEdit = [array]::LastIndexOf($events.ToArray(), $edits[-1])
$testedAfter = @($events | Select-Object -Skip ($lastEdit + 1) | Where-Object Kind -eq 'test')
if (-not $testedAfter) {
  $messages += "Code modifie sans tests ni type-check relances depuis la derniere modification. Lancer les tests concernes (stack Docker du worktree pour le back), ou indiquer en une ligne pourquoi ce n'est pas pertinent ici (ex. validation fonctionnelle demandee avant les tests)."
}

if ($messages) {
  [Console]::Error.WriteLine("Validation avant de rendre la main :`n`n" + ($messages -join "`n`n"))
  exit 2
}
exit 0
