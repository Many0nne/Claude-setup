<#
.SYNOPSIS
  Cree un thread T3 Code dans un projet et y envoie le premier message (session deleguee visible dans la sidebar T3).
  Passe par l'API locale du serveur T3 (port lu dans server-runtime.json) avec un jeton de session ephemere
  emis par le CLI officiel (`t3 auth session issue`), revoque a la fin.

.EXAMPLE
  .\t3-thread.ps1 -ProjectRoot C:\...\NOP -Title "fix-402 factures" -Prompt "Lis le brief ... puis execute-le." -Model sonnet
#>
param(
  [Parameter(Mandatory)][string]$ProjectRoot,
  [Parameter(Mandatory)][string]$Title,
  [Parameter(Mandatory)][string]$Prompt,
  [ValidateSet('sonnet', 'opus', 'haiku')][string]$Model = 'opus',
  [ValidateSet('low', 'medium', 'high', 'xhigh', 'max')][string]$Effort = 'medium',
  [string]$Branch,
  [string]$WorktreePath
)

$ErrorActionPreference = 'Stop'
$t3Dir = Join-Path $env:LOCALAPPDATA 'Programs\t3code'
$modelIds = @{ opus = 'claude-opus-5-5'; sonnet = 'claude-sonnet-5-5'; haiku = 'claude-haiku-5-5' }

# Cette methode permet d'appeler le CLI t3 embarque dans l'application lorsqu'aucun binaire t3 n'est installe dans le PATH.
function Invoke-T3Cli {
  $env:ELECTRON_RUN_AS_NODE = '1'
  # Le pipe force PowerShell a attendre l'exe (sous-systeme GUI) et a recuperer sa sortie.
  # Nom de l'exe variable selon le canal (Alpha, Beta...) : prendre celui present, hors desinstalleur.
  $exe = Get-ChildItem $t3Dir -Filter 'T3 Code*.exe' | Select-Object -First 1
  if (-not $exe) { throw "Executable T3 Code introuvable dans $t3Dir." }
  try { & $exe.FullName (Join-Path $t3Dir 'resources\server.asar\apps\server\dist\bin.mjs') @args 2>$null | ForEach-Object { $_ } }
  finally { Remove-Item Env:ELECTRON_RUN_AS_NODE }
}

# Cette methode permet d'appeler un endpoint de l'API locale T3 avec le jeton de session lorsqu'on lit ou modifie l'orchestration.
function Invoke-T3Api([string]$Method, [string]$Path, $Body) {
  $params = @{ Method = $Method; Uri = "$origin$Path"; Headers = @{ Authorization = "Bearer $token" }; ContentType = 'application/json' }
  if ($Body) { $params.Body = $Body | ConvertTo-Json -Depth 10 -Compress }
  Invoke-RestMethod @params
}

$runtime = Get-Content (Join-Path $env:USERPROFILE '.t3\userdata\server-runtime.json') -Raw | ConvertFrom-Json
$origin = $runtime.origin
if (-not $origin) { throw "Serveur T3 introuvable (server-runtime.json) : T3 Code doit etre ouvert." }

$issued = Invoke-T3Cli auth session issue --ttl 5m --label 'claude delegate' --json | Out-String | ConvertFrom-Json
$token = $issued.token
if (-not $token) { throw "Impossible d'emettre un jeton de session T3." }

try {
  $root = (Resolve-Path $ProjectRoot).Path.TrimEnd('\')
  $snapshot = Invoke-T3Api GET '/api/orchestration/snapshot'
  $project = $snapshot.projects | Where-Object { -not $_.deletedAt -and $_.workspaceRoot.TrimEnd('\') -ieq $root } | Select-Object -First 1
  if (-not $project) { throw "Aucun projet T3 pour $root : l'ajouter dans T3 (ou 't3 project add')." }

  $now = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
  $threadId = [guid]::NewGuid().ToString()
  $modelSelection = @{ instanceId = 'claudeAgent'; model = $modelIds[$Model]; options = @(@{ id = 'effort'; value = $Effort }, @{ id = 'fastMode'; value = $false }) }
  # Le bootstrap de thread.turn.start n'est traite que par le client web : via HTTP, creer le thread d'abord.
  Invoke-T3Api POST '/api/orchestration/dispatch' @{
    type            = 'thread.create'
    commandId       = [guid]::NewGuid().ToString()
    threadId        = $threadId
    projectId       = $project.id
    title           = $Title
    modelSelection  = $modelSelection
    runtimeMode     = 'full-access'
    interactionMode = 'default'
    branch          = if ($Branch) { $Branch } else { $null }
    worktreePath    = if ($WorktreePath) { $WorktreePath } else { $null }
    createdAt       = $now
  } | Out-Null
  Invoke-T3Api POST '/api/orchestration/dispatch' @{
    type            = 'thread.turn.start'
    commandId       = [guid]::NewGuid().ToString()
    threadId        = $threadId
    message         = @{ messageId = [guid]::NewGuid().ToString(); role = 'user'; text = $Prompt; attachments = @() }
    modelSelection  = $modelSelection
    runtimeMode     = 'full-access'
    interactionMode = 'default'
    createdAt       = $now
  } | Out-Null
  Write-Host "Thread T3 '$Title' cree dans le projet $($project.title) ($Model, effort $Effort) : $threadId"
} finally {
  if ($issued.sessionId) { Invoke-T3Cli auth session revoke $issued.sessionId | Out-Null }
}
