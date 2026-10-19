<#
.SYNOPSIS
  Cree, reutilise et demarre (ou supprime) des worktrees back et/ou front, avec ports et .env decales.

.DESCRIPTION
  Usage normal : <Branch> seule, quel que soit le cote ou elle existe. Le script detecte ou la branche
  existe (local ou origin) :
  - sur les deux depots, ou sur aucun (creee depuis -Base) : paire de worktrees ;
  - sur un seul depot : worktree de ce cote, et l'autre cote (branche dev du checkout principal) est
    lance en 2e instance branchee dessus. Rien a preciser, c'est automatique.

  -BackBranch / -FrontBranch ne servent que pour les cas que la detection ne couvre pas :
  - -BackBranch x -FrontBranch y : deux branches de noms differents ;
  - -BackBranch x seul (ou -FrontBranch y seul) : forcer un seul worktree alors que la branche existe
    des deux cotes, ou creer une nouvelle branche d'un seul cote.
  Combinaison avec <Branch> acceptee : `x -BackBranch x` = `-BackBranch x` (back seul),
  `x -FrontBranch y` = `-BackBranch x -FrontBranch y`. <Branch> avec les deux drapeaux est refuse.

  Idempotent : a relancer sans risque au debut de chaque tache. Un worktree deja present sur la
  bonne branche est reutilise tel quel (son .env et ses modifications sont conserves, seuls les
  ports sont realignes), le cote manquant est cree, et la paire garde son slot de ports. Les
  stacks sont demarrees (docker compose up -d --build) sauf avec -NoUp, puis le script attend que
  les deux URL repondent et verifie que le front appelle bien le back de la paire.

  Une 2e instance (lancee depuis le checkout principal, sans toucher a son .env) utilise un fichier
  compose d'override dans worktrees\.overrides\ et un nom de projet Compose dedie : base, containers
  et ports sont donc isoles du checkout principal qui continue a tourner.

.EXAMPLE
  .\scripts\nop-worktree.ps1 feature/subventions                       # cree/reutilise la paire et la demarre
  .\scripts\nop-worktree.ps1 feature/subventions -NoUp                 # sans demarrer les stacks
  .\scripts\nop-worktree.ps1 fix/err-nom-scenario                      # branche back uniquement : front = dev, automatiquement
  .\scripts\nop-worktree.ps1 feature/subventions -Remove               # down -v puis suppression (worktrees + 2e instance)

  Cas particuliers (detection auto insuffisante) :
  .\scripts\nop-worktree.ps1 -BackBranch fix/a -FrontBranch feature/b  # deux branches de noms differents
  .\scripts\nop-worktree.ps1 -BackBranch fix/nouvelle                  # nouvelle branche creee cote back seulement
  .\scripts\nop-worktree.ps1 -BackBranch fix/a -FrontBranch feature/b -Remove

  Registre de nettoyage (worktrees\.owners.json, lu par nop-worktree-cleanup.ps1) :
  .\scripts\nop-worktree.ps1 feature/x -NoUp -NoRegister               # creer sans inscrire la session courante (/delegate)
  .\scripts\nop-worktree.ps1 feature/x -RegisterThread <id>            # inscrire seulement un thread T3 (rien d'autre)

  Les worktrees sont crees dans NOP\worktrees\Outil-NOP-{backend,frontend}-<slug>. Le nom du dossier
  devient le nom du projet Compose : base, containers et images sont donc propres a la branche.
#>
param(
  [Parameter(Position = 0)][string]$Branch,
  [string]$BackBranch,
  [string]$FrontBranch,
  [string]$Base = 'dev',
  [int]$Slot = 0,
  [switch]$Up,  # conserve pour compatibilite : le demarrage est le comportement par defaut
  [switch]$NoUp,
  [switch]$Remove,
  [switch]$NoRegister,
  [string]$RegisterThread
)

$ErrorActionPreference = 'Stop'
$Up = -not $NoUp

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

# Cette methode permet de trouver les branches (locales ou origin) dont le nom ne differe que par - / _ ou la casse
# lorsqu'une branche demandee n'existe pas, pour ne pas en creer une nouvelle sur une faute de frappe.
function Find-SimilarBranch([string]$Main, [string]$Branch) {
  $key = $Branch.ToLower() -replace '_', '-'
  git -C $Main for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin |
    ForEach-Object { $_ -replace '^origin/', '' } |
    Where-Object { $_ -ne $Branch -and ($_.ToLower() -replace '_', '-') -eq $key } |
    Select-Object -Unique
}

# Cette methode permet de savoir si un dossier est encore inscrit comme worktree du depot lorsqu'un -Remove a pu etre interrompu.
function Test-WorktreeRegistered([string]$Main, [string]$Dir) {
  $target = (Resolve-Path $Dir).Path.Replace('\', '/').TrimEnd('/')
  $paths = git -C $Main worktree list --porcelain | Where-Object { $_ -like 'worktree *' } | ForEach-Object { $_.Substring(9).TrimEnd('/') }
  return [bool]($paths | Where-Object { $_ -ieq $target })
}

# Cette methode permet de lire la branche courante d'un worktree lorsqu'il existe deja.
function Get-WorktreeBranch([string]$Dir) {
  return (git -C $Dir rev-parse --abbrev-ref HEAD)
}

# Cette methode permet de lire le slot deja attribue a un cote lorsque son .env ou son override existe.
function Get-SideSlot($Side) {
  if ($Side.Dir -and (Test-Path (Join-Path $Side.Dir '.env'))) {
    $origin = if ($Side.Short -eq 'back') { 8000 } else { 3000 }
    $m = Select-String -Path (Join-Path $Side.Dir '.env') -Pattern "^$($Side.PortVar)=(\d+)" | Select-Object -First 1
    if ($m) { return [int](([int]$m.Matches[0].Groups[1].Value - $origin) / 100) }
  }
  if (Test-Path $Side.Override) {
    $m = Select-String -Path $Side.Override -Pattern '^# slot=(\d+)' | Select-Object -First 1
    if ($m) { return [int]$m.Matches[0].Groups[1].Value }
  }
  return 0
}

# Cette methode permet d'attendre qu'une URL reponde (code HTTP < 500) lorsque la stack vient d'etre demarree.
function Wait-Url([string]$Url, [int]$TimeoutSec = 180) {
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while ((Get-Date) -lt $deadline) {
    try {
      $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -SkipHttpErrorCheck
      if ($r.StatusCode -lt 500) { return $r.StatusCode }
    } catch { }
    Start-Sleep -Seconds 3
  }
  return $null
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

# Registre des worktrees ouverts depuis une session Claude (lu par nop-worktree-cleanup.ps1, qui arrete leurs stacks
# quand tous leurs threads T3 sont settled, et les supprime quand ils sont tous archives ou supprimes).
$ownersFile = Join-Path $root 'worktrees\.owners.json'

# Cette methode permet de lire le registre des worktrees lorsqu'on doit l'enrichir ou le nettoyer.
function Get-Owners {
  if (Test-Path $ownersFile) { return @(Get-Content $ownersFile -Raw | ConvertFrom-Json) }
  return @()
}

# Cette methode permet d'inscrire la session Claude courante (ou le thread T3 donne) comme utilisatrice d'un couple
# de branches lorsque le script cree ou reutilise un worktree depuis Claude Code, ou quand /delegate a cree son thread.
function Register-Owner([string]$Back, [string]$Front, [string]$Thread) {
  $session = if ($Thread) { $null } else { $env:CLAUDE_CODE_SESSION_ID }
  if (-not ($session -or $Thread)) { return }
  # @() : PowerShell deroule le tableau renvoye, une seule entree reviendrait comme objet nu (sans +=).
  $owners = @(Get-Owners)
  $entry = $owners | Where-Object { $_.back -eq $Back -and $_.front -eq $Front } | Select-Object -First 1
  if (-not $entry) {
    $entry = [pscustomobject]@{ back = $Back; front = $Front; sessions = @(); threads = @() }
    $owners += $entry
  }
  $thread = $Thread
  if ($session) {
    if ($session -notin $entry.sessions) { $entry.sessions = @($entry.sessions) + $session }
    # Le thread T3 (stable meme apres /clear) ; vide si la session ne tourne pas dans T3.
    $thread = python -I (Join-Path $PSScriptRoot 't3_threads.py') thread-of $session 2>$null
  }
  if ($thread -and $thread -notin $entry.threads) { $entry.threads = @($entry.threads) + $thread }
  ConvertTo-Json @($owners) -Depth 4 | Set-Content $ownersFile
}

# Cette methode permet de retirer du registre les entrees d'une branche lorsque ses worktrees viennent d'etre supprimes.
function Unregister-Owner([string]$Back, [string]$Front) {
  if (-not (Test-Path $ownersFile)) { return }
  $owners = @(Get-Owners | Where-Object { -not (($Back -and $_.back -eq $Back) -or ($Front -and $_.front -eq $Front)) })
  ConvertTo-Json @($owners) -Depth 4 | Set-Content $ownersFile
}

$backMain = Join-Path $root 'Outil-NOP-backend'
$frontMain = Join-Path $root 'Outil-NOP-frontend'

# <Branch> combinee a un seul drapeau : meme nom = forcer ce cote seul, nom different = <Branch> pour l'autre cote.
if ($Branch -and ($BackBranch -or $FrontBranch)) {
  if ($BackBranch -and $FrontBranch) {
    throw "<Branch> en trop : -BackBranch et -FrontBranch fixent deja les deux cotes."
  }
  if ($BackBranch -ne $Branch -and $FrontBranch -ne $Branch) {
    if ($BackBranch) { $FrontBranch = $Branch } else { $BackBranch = $Branch }
  }
  $Branch = $null
  Write-Host "Branches : back = $(if ($BackBranch) { "'$BackBranch'" } else { 'dev (2e instance)' }), front = $(if ($FrontBranch) { "'$FrontBranch'" } else { 'dev (2e instance)' })."
}
if (-not ($Branch -or $BackBranch -or $FrontBranch)) {
  throw "Preciser <Branch> (cote(s) detecte(s) automatiquement). -BackBranch / -FrontBranch seulement pour deux branches differentes ou forcer un seul cote."
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
    elseif (-not $inBack -and -not $inFront) {
      $similar = @($backMain, $frontMain | ForEach-Object { Find-SimilarBranch $_ $Branch }) | Select-Object -Unique
      if ($similar) { throw "'$Branch' n'existe nulle part, mais '$($similar -join "', '")' existe : verifier le nom (- / _ / casse). Rien n'a ete cree." }
    }
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
  # Verification prealable des deux cotes : sinon un cote serait deja down -v / supprime quand l'autre refuse.
  $dirty = @()
  foreach ($s in $sides) {
    if ($s.Dir -and (Test-Path $s.Dir) -and (Test-WorktreeRegistered $s.Main $s.Dir)) {
      $changes = @(git -C $s.Dir status --porcelain)
      if ($changes.Count -gt 0) { $dirty += "$($s.Dir) :`n" + (($changes | ForEach-Object { "    $_" }) -join "`n") }
    }
  }
  if ($dirty.Count -gt 0) {
    throw ("Modifications non commitees, rien n'a ete supprime :`n" + ($dirty -join "`n") +
      "`nLes commiter, les stasher (git -C <dossier> stash -u) ou les jeter (git -C <dossier> restore . ; git -C <dossier> clean -fd), puis relancer -Remove.")
  }
  $removed = 0
  foreach ($s in $sides) {
    if ($s.Dir -and (Test-Path $s.Dir)) {
      $removed++
      if (Test-Path (Join-Path $s.Dir $s.Compose)) {
        Push-Location $s.Dir
        try { docker compose down -v --rmi local } finally { Pop-Location }
      }
      if (Test-WorktreeRegistered $s.Main $s.Dir) {
        git -C $s.Main worktree remove $s.Dir
        if ($LASTEXITCODE -ne 0) { throw "Suppression du worktree $($s.Dir) echouee (terminal ouvert dedans ?)" }
      } elseif (-not (Get-ChildItem -Force $s.Dir)) {
        # Reliquat d'un -Remove interrompu : git a deja desinscrit le worktree mais n'a pas pu supprimer le dossier verrouille.
        Remove-Item $s.Dir
        if (Test-Path $s.Dir) { throw "Dossier vide $($s.Dir) non supprime (terminal ouvert dedans ?)" }
      } else {
        throw "$($s.Dir) n'est pas un worktree git mais n'est pas vide : a verifier et supprimer a la main."
      }
    }
    if (Test-Path $s.Override) {
      $removed++
      Invoke-ExtraCompose $s @('down', '-v', '--rmi', 'local')
      Remove-Item $s.Override
    }
  }
  Unregister-Owner $BackBranch $FrontBranch
  if ($removed -eq 0) { Write-Host "Rien a supprimer : aucun worktree ni 2e instance pour ces branches." }
  else { Write-Host "Worktrees et 2e instances supprimes (les branches git sont conservees)." }
  return
}

if ($RegisterThread) {
  Register-Owner $BackBranch $FrontBranch $RegisterThread
  Write-Host "Thread $RegisterThread inscrit pour le nettoyage de $(@($BackBranch, $FrontBranch) | Where-Object { $_ } | Select-Object -Unique)."
  return
}

# Verification prealable des dossiers existants : un worktree sur la bonne branche est reutilise,
# tout autre dossier bloque avant toute creation (sinon un cote serait deja cree quand l'autre echoue).
$problems = @()
foreach ($s in $sides | Where-Object { $_.Branch }) {
  $s.Reused = $false
  if (-not (Test-Path $s.Dir)) { continue }
  if (-not (Test-WorktreeRegistered $s.Main $s.Dir)) {
    $problems += "$($s.Dir) existe mais n'est pas un worktree de $($s.Main) (reliquat ? -Remove puis relancer)"
    continue
  }
  $current = Get-WorktreeBranch $s.Dir
  if ($current -ne $s.Branch) {
    $problems += "$($s.Dir) est sur '$current' au lieu de '$($s.Branch)'"
    continue
  }
  $s.Reused = $true
}
if ($problems.Count -gt 0) { throw ("Rien n'a ete cree :`n  " + ($problems -join "`n  ")) }
# Inscription apres la verification : un echec ne laisse pas d'entree orpheline dans le registre.
if (-not $NoRegister) { Register-Owner $BackBranch $FrontBranch }

# Choix du slot : celui deja attribue a la paire s'il existe, sinon le premier numero >= 1 libre.
if ($Slot -le 0) {
  $own = @($sides | ForEach-Object { Get-SideSlot $_ } | Where-Object { $_ -gt 0 } | Select-Object -Unique)
  if ($own.Count -gt 1) { throw "Les deux cotes de la paire ont des slots differents ($($own -join ', ')) : preciser -Slot." }
  if ($own.Count -eq 1) {
    $Slot = $own[0]
  } else {
    $used = Get-UsedSlot
    $Slot = 1
    while ($used -contains $Slot) { $Slot++ }
  }
}
$webPort = 8000 + 100 * $Slot
$frontPort = 3000 + 100 * $Slot
$pgadminPort = 5050 + $Slot

# Worktrees deja presents : conserves tels quels, alignes sur origin seulement s'ils sont propres.
foreach ($r in $sides | Where-Object { $_.Branch -and $_.Reused }) {
  Write-Host "  $($r.Short) : worktree existant reutilise ($($r.Dir))."
  git -C $r.Main fetch origin --quiet
  git -C $r.Main show-ref --verify --quiet "refs/remotes/origin/$($r.Branch)"
  if ($LASTEXITCODE -eq 0) {
    if (@(git -C $r.Dir status --porcelain).Count -eq 0) { Sync-WithOrigin $r.Dir $r.Branch }
    else { Write-Host "  $($r.Short) : modifications en cours, branche non realignee sur origin." }
  }
  $global:LASTEXITCODE = 0
  if (-not (Test-Path (Join-Path $r.Dir '.env'))) { Copy-Item (Join-Path $r.Main '.env') (Join-Path $r.Dir '.env') }
}

# Creation des worktrees pour les cotes qui ont une branche et pas encore de dossier.
foreach ($r in $sides | Where-Object { $_.Branch -and -not $_.Reused }) {
  $b = $r.Branch
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
    # --no-track : sinon la branche suit origin/$Base et un simple `git push` partirait sur $Base.
    git -C $r.Main worktree add --no-track -b $b $r.Dir "origin/$Base"
  }
  if ($LASTEXITCODE -ne 0) { throw "git worktree add a echoue pour $($r.Name)" }
  Copy-Item (Join-Path $r.Main '.env') (Join-Path $r.Dir '.env')
  # settings.local.json est ignore par git : sans copie, une session ouverte dans le worktree perd le hook block-env.
  $localSettings = Join-Path $r.Main '.claude\settings.local.json'
  if (Test-Path $localSettings) { Copy-Item $localSettings (Join-Path $r.Dir '.claude\settings.local.json') }
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
# Un cote passe d'une 2e instance a un worktree : son override est perime (meme nom de projet Compose,
# les containers sont repris par le `up` du worktree).
foreach ($s in $sides | Where-Object { $_.Branch -and (Test-Path $_.Override) }) {
  Remove-Item $s.Override
  Write-Host "  $($s.Short) : override de 2e instance supprime (remplace par le worktree)."
}
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
  if ($Up) { throw "$msg Demarrage annule (worktrees crees : rebaser puis relancer, ou -Remove pour les supprimer)." }
  Write-Warning $msg
}

if ($Up) {
  # Les ports passent par l'interpolation du compose (${WEB_PORT}, ${FRONTEND_PORT}), ou une variable du shell l'emporte sur le .env :
  # on les impose donc aussi pour les worktrees, sinon un WEB_PORT=8000 herite du terminal fait binder le port du checkout principal.
  $vars = @{ WEB_PORT = "$webPort"; PGADMIN_PORT = "$pgadminPort"; FRONTEND_PORT = "$frontPort" }
  $saved = @{}
  foreach ($k in $vars.Keys) { $saved[$k] = [Environment]::GetEnvironmentVariable($k); [Environment]::SetEnvironmentVariable($k, $vars[$k]) }
  try {
    foreach ($s in $sides) {
      if ($s.Branch) {
        Push-Location $s.Dir
        try {
          docker compose up -d --build
          if ($LASTEXITCODE -ne 0) { throw "docker compose up a echoue pour $($s.Dir)" }
        } finally { Pop-Location }
      } else {
        Invoke-ExtraCompose $s @('up', '-d', '--build')
      }
    }
  } finally { foreach ($k in $vars.Keys) { [Environment]::SetEnvironmentVariable($k, $saved[$k]) } }
}

# Verification finale : les deux URL repondent et le front appelle bien le back de la paire.
$status = @{}
if ($Up) {
  foreach ($s in $sides) {
    $url = if ($s.Short -eq 'back') { "http://localhost:$webPort/api/" } else { "http://localhost:$frontPort" }
    $code = Wait-Url $url
    $status[$s.Short] = if ($code) { "OK ($code)" } else { "NE REPOND PAS" }
  }
  $frontApi = if ($front.Branch) {
    Push-Location $front.Dir
    try { docker compose exec -T $front.Service printenv VITE_API_BASE_URL } finally { Pop-Location }
  } else {
    Invoke-ExtraCompose $front @('exec', '-T', $front.Service, 'printenv', 'VITE_API_BASE_URL')
  }
  if ("$frontApi".Trim() -ne "http://localhost:$webPort") {
    $status['front'] += " - ATTENTION : VITE_API_BASE_URL=$frontApi au lieu de http://localhost:$webPort"
  }
}

Write-Host ""
Write-Host "Slot $Slot"
foreach ($s in $sides) {
  $url = if ($s.Short -eq 'back') { "http://localhost:$webPort/api/" } else { "http://localhost:$frontPort" }
  $where = if ($s.Branch) { "worktree '$($s.Branch)' : $($s.Dir)" } else { "2e instance de $($s.Main) (dev) : projet $($s.Project)" }
  $state = if ($Up) { " [$($status[$s.Short])]" } else { "" }
  Write-Host ("  {0,-6}: {1}{2}   ({3})" -f $s.Short, $url, $state, $where)
}
if (-not $Up) { Write-Host "Stacks non demarrees (-NoUp) : relancer sans -NoUp pour les demarrer." }
elseif (@($status.Values | Where-Object { $_ -notlike 'OK*' -or $_ -like '*ATTENTION*' }).Count -gt 0) {
  throw "Stack incomplete : voir les statuts ci-dessus (docker compose logs dans le dossier concerne)."
}
