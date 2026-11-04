<#
.SYNOPSIS
  Coche les taches Todoist ouvertes dont toutes les PR GitHub citees (lien github.com/<org>/<depot>/pull/<n> dans le
  titre ou la description) sont mergees. Une tache sans lien de PR, ou dont une PR est ouverte ou fermee sans merge,
  n'est pas touchee. Tous les projets Todoist sont examines.
  Token : variable d'environnement utilisateur TODOIST_API_TOKEN. PR lues avec `gh` (deja authentifie).
  Lance toutes les 10 minutes par la tache planifiee "Todoist coche auto" (install-todoist-coche-auto.ps1) ;
  journal dans ~/.claude/state/todoist-coche-auto.log.

.EXAMPLE
  & "$HOME\.claude\scripts\todoist-coche-auto.ps1" -DryRun
#>
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$api = 'https://api.todoist.com/api/v1'
$logFile = Join-Path $HOME '.claude\state\todoist-coche-auto.log'

# Cette methode permet de tracer une action (console et journal) lorsqu'une tache est cochee ou qu'une erreur survient ;
# avec -Once, un message deja present dans la fin du journal n'est pas repete (execution toutes les 10 minutes).
function Write-Log([string]$Message, [switch]$Once) {
  $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm') $Message"
  Write-Host $line
  if ($DryRun) { return }
  if ($Once -and (Test-Path $logFile) -and (@(Get-Content $logFile -Tail 200) -replace '^\S+ \S+ ', '') -contains $Message) { return }
  Add-Content $logFile $line
}

# Cette methode permet de lire toutes les pages d'une liste de l'API Todoist v1 lorsque les resultats sont pagines (next_cursor).
function Get-TodoistPages([string]$Path, [hashtable]$Headers) {
  $cursor = $null
  do {
    $uri = "$api/$Path$(if ($Path -match '\?') { '&' } else { '?' })limit=200$(if ($cursor) { "&cursor=$cursor" })"
    $page = Invoke-RestMethod -Uri $uri -Headers $Headers
    $page.results
    $cursor = $page.next_cursor
  } while ($cursor)
}

$token = [Environment]::GetEnvironmentVariable('TODOIST_API_TOKEN', 'User')
if (-not $token) { $token = $env:TODOIST_API_TOKEN }
if (-not $token) { Write-Log 'ECHEC : variable TODOIST_API_TOKEN absente' -Once; return }
$headers = @{ Authorization = "Bearer $token" }

try {
  $prStates = @{}
  foreach ($task in Get-TodoistPages 'tasks' $headers) {
    $prs = [regex]::Matches("$($task.content) $($task.description)", 'github\.com/([\w.-]+/[\w.-]+)/pull/(\d+)') |
      ForEach-Object { "$($_.Groups[1].Value)#$($_.Groups[2].Value)" } | Select-Object -Unique
    if (-not $prs) { continue }
    foreach ($pr in $prs) {
      if ($prStates.ContainsKey($pr)) { continue }
      $repo, $number = $pr -split '#'
      $state = gh pr view $number --repo $repo --json state --jq .state 2>$null
      $prStates[$pr] = if ($LASTEXITCODE -eq 0) { $state } else { 'INCONNU' }
    }
    if (@($prs | Where-Object { $prStates[$_] -ne 'MERGED' })) { continue }
    if ($DryRun) { Write-Host "A COCHER '$($task.content)' (PR mergees : $($prs -join ', '))"; continue }
    Invoke-RestMethod -Method Post -Uri "$api/tasks/$($task.id)/close" -Headers $headers | Out-Null
    Write-Log "COCHE '$($task.content)' (PR mergees : $($prs -join ', '))"
  }
} catch {
  Write-Log "ECHEC : $($_.Exception.Message)" -Once
}
