<#
.SYNOPSIS
  Cree (ou supprime) des worktrees back et/ou front, avec ports et .env decales.

.DESCRIPTION
  Trois modes :
  - <Branch> seule : detecte ou la branche existe (local ou origin). Sur les deux depots, ou sur aucun
    (creee depuis -Base) : paire de worktrees. Sur un seul : worktree de ce cote, et l'autre cote
    (branche dev du checkout principal) est lance en 2e instance branchee dessus.
  - -BackBranch x -FrontBranch y : paire de worktrees avec deux branches differentes.
  - -BackBranch x seul (ou -FrontBranch y seul) : worktree d'un cote, 2e instance de l'autre cote.

  Une 2e instance (lancee depuis le checkout principal, sans toucher a son .env) utilise un fichier
  compose d'override dans worktrees\.overrides\ et un nom de projet Compose dedie : base, containers
  et ports sont donc isoles du checkout principal qui continue a tourner.

.EXAMPLE
  .\scripts\nop-worktree.ps1 feature/subventions                       # auto : paire ou un seul cote selon l'existence
  .\scripts\nop-worktree.ps1 feature/subventions -Up                   # puis docker compose up -d --build
  .\scripts\nop-worktree.ps1 -BackBranch fix/err-nom-scenario -Up      # back sur la branche, front = dev
  .\scripts\nop-worktree.ps1 -BackBranch fix/a -FrontBranch feature/b  # deux branches differentes
  .\scripts\nop-worktree.ps1 feature/subventions -Remove               # down -v puis suppression (worktrees + 2e instance)
  .\scripts\nop-worktree.ps1 -BackBranch fix/a -FrontBranch feature/b -Remove

  Les worktrees sont crees dans NOP\worktrees\Outil-NOP-{backend,frontend}-<slug>. Le nom du dossier
  devient le nom du projet Compose : base, containers et images sont donc propres a la branche.
#>
param(
  [Parameter(Position = 0)][string]$Branch,
  [string]$BackBranch,
  [string]$FrontBranch,
  [string]$Base = 'dev',
  [int]$Slot = 0,
  [switch]$Up,
  [switch]$Remove
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$overridesDir = Join-Path $root 'worktrees\.overrides'

# Cette fonction permet de fixer KEY=valeur dans un fichier .env lorsque la cle existe deja ou non.
function Set-EnvVar([string]$Path, [string]$Key, [string]$Value) {
  $text = Get-Content -Raw -Path $Path
  if ($text -match "(?m)^$Key=") {
    $text = [regex]::Replace($text, "(?m)^$Key=.*$", "$Key=$Value")
  } else {
    $text = $text.TrimEnd() + "`n$Key=$Value`n"
  }
  Set-Content -Path $Path -Value $text -NoNewline
}

# Cette methode permet d'aligner la branche locale du worktree sur origin lorsque les deux existent.
# Fast-forward si possible ; reset si la locale n'a que des commits deja presents sur origin (rebase/force-push) ; sinon on la garde.
function Sync-WithOrigin([string]$Dir, [string]$Branch) {
  $remoteRef = "origin/$Branch"
  if ((git -C $Dir rev-parse HEAD) -eq (git -C $Dir rev-parse $remoteRef)) { return }
  git -C $Dir merge-base --is-ancestor HEAD $remoteRef
  if ($LASTEXITCODE -eq 0) {
    git -C $Dir merge --ff-only $remoteRef | Out-Null
    Write-Host "  '$Branch' avance sur $remoteRef."
    return
  }
  $unpushed = @(git -C $Dir cherry $remoteRef HEAD | Where-Object { $_ -like '+*' })
  if ($unpushed.Count -gt 0) {
    Write-Warning "'$Branch' a $($unpushed.Count) commit(s) locaux absents de $remoteRef : branche locale conservee, a synchroniser a la main."
    return
  }
  $old = git -C $Dir rev-parse --short HEAD
  git -C $Dir reset --hard $remoteRef | Out-Null
  Write-Host "  '$Branch' realignee sur $remoteRef (ancien HEAD local : $old, retrouvable via reflog)."
}

# Cette methode permet de savoir si une branche existe en local ou sur origin lorsque le depot a ete fetch.
function Test-BranchExists([string]$Main, [string]$Branch) {
  git -C $Main show-ref --verify --quiet "refs/heads/$Branch"
  if ($LASTEXITCODE -eq 0) { return $true }
  git -C $Main show-ref --verify --quiet "refs/remotes/origin/$Branch"
  return ($LASTEXITCODE -eq 0)
}

# Cette methode permet de lancer docker compose sur le checkout principal avec un fichier d'override lorsqu'un cote n'a pas de worktree.
function Invoke-ExtraCompose($Side, [string[]]$ComposeArgs) {
  docker compose --project-directory $Side.Main -p $Side.Project -f (Join-Path $Side.Main $Side.Compose) -f $Side.Override @ComposeArgs
  if ($LASTEXITCODE -ne 0) { throw "docker compose a echoue pour $($Side.Project)" }
}

# Cette methode permet de lister les slots deja pris par des worktrees ou des 2e instances.
function Get-UsedSlot {
  $used = @()
  $wt = Join-Path $root 'worktrees'
  $probes = @(
    @{ Filter = 'Outil-NOP-backend-*'; Key = 'WEB_PORT'; Origin = 8000 },
    @{ Filter = 'Outil-NOP-frontend-*'; Key = 'FRONTEND_PORT'; Origin = 3000 }
  )
  foreach ($p in $probes) {
    Get-ChildItem -Path $wt -Directory -Filter $p.Filter -ErrorAction SilentlyContinue | ForEach-Object {
      $envFile = Join-Path $_.FullName '.env'
      if (Test-Path $envFile) {
        $m = Select-String -Path $envFile -Pattern "^$($p.Key)=(\d+)" | Select-Object -First 1
        if ($m) { $used += [int](($m.Matches[0].Groups[1].Value - $p.Origin) / 100) }
      }
    }
  }
  Get-ChildItem -Path $overridesDir -Filter '*.yml' -ErrorAction SilentlyContinue | ForEach-Object {
    $m = Select-String -Path $_.FullName -Pattern '^# slot=(\d+)' | Select-Object -First 1
    if ($m) { $used += [int]$m.Matches[0].Groups[1].Value }
  }
  return $used
}

$backMain = Join-Path $root 'Outil-NOP-backend'
$frontMain = Join-Path $root 'Outil-NOP-frontend'

if ($Branch -and ($BackBranch -or $FrontBranch)) {
  throw "Utiliser soit <Branch>, soit -BackBranch / -FrontBranch, pas les deux."
}
if (-not ($Branch -or $BackBranch -or $FrontBranch)) {
  throw "Preciser <Branch>, ou -BackBranch et/ou -FrontBranch."
}

# Resolution des branches : avec <Branch> seule, un cote sans la branche reste sur le checkout principal.
if ($Branch) {
  $BackBranch = $Branch
  $FrontBranch = $Branch
  if (-not $Remove) {
    git -C $backMain fetch origin --quiet
    git -C $frontMain fetch origin --quiet
    $inBack = Test-BranchExists $backMain $Branch
    $inFront = Test-BranchExists $frontMain $Branch
    if ($inBack -and -not $inFront) { $FrontBranch = $null }
    elseif ($inFront -and -not $inBack) { $BackBranch = $null }
  }
}

function Get-Slug([string]$Name) { if ($Name) { $Name -replace '[^A-Za-z0-9._-]', '-' } else { $null } }
$backSlug = Get-Slug $BackBranch
$frontSlug = Get-Slug $FrontBranch

$sides = @(
  @{ Name = 'backend'; Short = 'back'; Main = $backMain; Compose = 'compose.yaml'; PortVar = 'WEB_PORT'; Service = 'web'; Branch = $BackBranch; Slug = $backSlug; OtherSlug = $frontSlug },
  @{ Name = 'frontend'; Short = 'front'; Main = $frontMain; Compose = 'docker-compose.yml'; PortVar = 'FRONTEND_PORT'; Service = 'frontend'; Branch = $FrontBranch; Slug = $frontSlug; OtherSlug = $backSlug }
)
foreach ($s in $sides) {
  $projectSlug = if ($s.Slug) { $s.Slug } else { $s.OtherSlug }
  $s.Dir = if ($s.Slug) { Join-Path $root "worktrees\Outil-NOP-$($s.Name)-$($s.Slug)" } else { $null }
  $s.Project = "nop-$($s.Short)-$projectSlug".ToLower()
  $s.Override = Join-Path $overridesDir "$($s.Project).yml"
}
$back = $sides[0]
$front = $sides[1]

if ($Remove) {
  foreach ($s in $sides) {
    if ($s.Dir -and (Test-Path $s.Dir)) {
      Push-Location $s.Dir
      try { docker compose down -v --rmi local } finally { Pop-Location }
      git -C $s.Main worktree remove $s.Dir
      if ($LASTEXITCODE -ne 0) { throw "Suppression du worktree $($s.Dir) echouee (terminal ouvert dedans ?)" }
    }
    if (Test-Path $s.Override) {
      Invoke-ExtraCompose $s @('down', '-v', '--rmi', 'local')
      Remove-Item $s.Override
    }
  }
  Write-Host "Worktrees et 2e instances supprimes (les branches git sont conservees)."
  return
}

# Choix du slot : premier numero >= 1 dont les ports ne sont pas deja pris par un autre worktree ou une 2e instance.
if ($Slot -le 0) {
  $used = Get-UsedSlot
  $Slot = 1
  while ($used -contains $Slot) { $Slot++ }
}
$webPort = 8000 + 100 * $Slot
$frontPort = 3000 + 100 * $Slot
$pgadminPort = 5050 + $Slot

# Creation des worktrees pour les cotes qui ont une branche.
foreach ($r in $sides | Where-Object { $_.Branch }) {
  $b = $r.Branch
  if (Test-Path $r.Dir) { throw "Le dossier existe deja : $($r.Dir)" }
  git -C $r.Main fetch origin --quiet
  git -C $r.Main show-ref --verify --quiet "refs/heads/$b"
  $local = $LASTEXITCODE -eq 0
  git -C $r.Main show-ref --verify --quiet "refs/remotes/origin/$b"
  $remote = $LASTEXITCODE -eq 0
  if ($local) {
    git -C $r.Main worktree add $r.Dir $b
    if ($LASTEXITCODE -ne 0) { throw "git worktree add a echoue pour $($r.Name)" }
    if ($remote) { Sync-WithOrigin $r.Dir $b; $global:LASTEXITCODE = 0 }
  } elseif ($remote) {
    git -C $r.Main worktree add --track -b $b $r.Dir "origin/$b"
  } else {
    git -C $r.Main worktree add -b $b $r.Dir "origin/$Base"
  }
  if ($LASTEXITCODE -ne 0) { throw "git worktree add a echoue pour $($r.Name)" }
  Copy-Item (Join-Path $r.Main '.env') (Join-Path $r.Dir '.env')
}

# Ports : le back est toujours sur $webPort et le front sur $frontPort, quel que soit le mode (worktree ou 2e instance).
if ($back.Branch) {
  $backEnv = Join-Path $back.Dir '.env'
  Set-EnvVar $backEnv 'COMPOSE_PROJECT_NAME' $back.Project
  Set-EnvVar $backEnv 'WEB_PORT' $webPort
  Set-EnvVar $backEnv 'PGADMIN_PORT' $pgadminPort
  Set-EnvVar $backEnv 'FRONTEND_BASE_URL' "http://localhost:$frontPort"
  Set-EnvVar $backEnv 'DJANGO_CORS_ALLOWED_ORIGINS' "http://localhost:$frontPort"
}
if ($front.Branch) {
  $frontEnv = Join-Path $front.Dir '.env'
  Set-EnvVar $frontEnv 'COMPOSE_PROJECT_NAME' $front.Project
  Set-EnvVar $frontEnv 'FRONTEND_PORT' $frontPort
  Set-EnvVar $frontEnv 'VITE_API_BASE_URL' "http://localhost:$webPort"
}

# 2e instance : les env_file des composes ne sont pas surchargeables par le shell, donc override `environment:`.
New-Item -ItemType Directory -Force -Path $overridesDir | Out-Null
if (-not $back.Branch) {
  Set-Content -Path $back.Override -Value @"
# slot=$Slot
services:
  web:
    environment:
      FRONTEND_BASE_URL: http://localhost:$frontPort
      DJANGO_CORS_ALLOWED_ORIGINS: http://localhost:$frontPort
"@
}
if (-not $front.Branch) {
  Set-Content -Path $front.Override -Value @"
# slot=$Slot
services:
  frontend:
    environment:
      VITE_API_BASE_URL: http://localhost:$webPort
"@
}

# Verifie que les compose lisent bien les ports du .env (branche basee sur un dev trop ancien sinon).
$missing = @($sides | Where-Object { $_.Branch } | Where-Object {
    -not (Select-String -Path (Join-Path $_.Dir $_.Compose) -Pattern ([regex]::Escape($_.PortVar)) -Quiet)
  })
if ($missing.Count -gt 0) {
  $names = ($missing | ForEach-Object { "$($_.PortVar) dans $(Join-Path $_.Dir $_.Compose)" }) -join ', '
  $msg = "Ports en dur : $names. La branche doit etre rebasee sur dev (commit de parametrage des ports)."
  if ($Up) { throw "$msg Demarrage annule (worktrees crees : utiliser -Remove pour les supprimer)." }
  Write-Warning $msg
}

if ($Up) {
  foreach ($s in $sides) {
    if ($s.Branch) {
      Push-Location $s.Dir
      try { docker compose up -d --build } finally { Pop-Location }
    } else {
      # Les ports passent par l'interpolation du compose (${WEB_PORT}, ${FRONTEND_PORT}), prioritaire sur le .env principal.
      $vars = @{ WEB_PORT = "$webPort"; PGADMIN_PORT = "$pgadminPort"; FRONTEND_PORT = "$frontPort" }
      $saved = @{}
      foreach ($k in $vars.Keys) { $saved[$k] = [Environment]::GetEnvironmentVariable($k); [Environment]::SetEnvironmentVariable($k, $vars[$k]) }
      try { Invoke-ExtraCompose $s @('up', '-d', '--build') }
      finally { foreach ($k in $vars.Keys) { [Environment]::SetEnvironmentVariable($k, $saved[$k]) } }
    }
  }
}

Write-Host ""
Write-Host "Slot $Slot"
foreach ($s in $sides) {
  $url = if ($s.Short -eq 'back') { "http://localhost:$webPort/api/" } else { "http://localhost:$frontPort" }
  $where = if ($s.Branch) { "worktree '$($s.Branch)' : $($s.Dir)" } else { "2e instance de $($s.Main) (dev) : projet $($s.Project)" }
  Write-Host ("  {0,-6}: {1}   ({2})" -f $s.Short, $url, $where)
}
if (-not $Up) { Write-Host "Demarrer : docker compose up -d --build dans chaque worktree. Une 2e instance n'est lancee que par -Up (sinon -Remove puis relancer avec -Up)." }
