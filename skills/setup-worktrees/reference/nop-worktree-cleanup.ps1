<#
.SYNOPSIS
  Libere les ressources des worktrees dont le travail est termine cote T3, en deux paliers :
  - tous les threads settled (ou settled + archives) : arret des containers (reversible, relancer
    nop-worktree.ps1 <branche> pour reprendre) ;
  - tous les threads archives ou supprimes : suppression (nop-worktree.ps1 -Remove).
  Un thread settled qui recoit un nouveau message redevient actif : rien n'est touche. Une session inscrite
  pas encore rattachee a un thread (premier tour en cours) et active depuis moins de 30 min bloque aussi l'entree.
  Le lien worktree -> threads vient du registre worktrees\.owners.json, rempli par nop-worktree.ps1.
  Garde-fous de suppression : rien n'est supprime s'il reste des modifications non commitees, ou des commits
  absents d'origin (sauf PR mergee, cas du squash-merge avec branche distante supprimee).
  Lance toutes les 10 minutes par la tache planifiee "NOP worktree cleanup" (install-cleanup-task.ps1) ;
  journal dans worktrees\.cleanup.log.

.EXAMPLE
  .\scripts\nop-worktree-cleanup.ps1 -DryRun
#>
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$ownersFile = Join-Path $root 'worktrees\.owners.json'
$logFile = Join-Path $root 'worktrees\.cleanup.log'
$helper = Join-Path $PSScriptRoot 't3_threads.py'
$repos = @{ back = @{ Main = Join-Path $root 'Outil-NOP-backend'; Name = 'backend' }; front = @{ Main = Join-Path $root 'Outil-NOP-frontend'; Name = 'frontend' } }

# Cette methode permet de tracer une decision du nettoyage (console et journal) lorsqu'un worktree est arrete, garde ou supprime ;
# avec -Once, un message deja present dans la fin du journal n'est pas repete (execution toutes les 10 minutes).
function Write-Log([string]$Message, [switch]$Once) {
  $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm') $Message"
  Write-Host $line
  if ($DryRun) { return }
  if ($Once -and (Test-Path $logFile) -and (@(Get-Content $logFile -Tail 200) -replace '^\S+ \S+ ', '') -contains $Message) { return }
  Add-Content $logFile $line
}

# Cette methode permet de savoir si une session Claude a ecrit son transcript recemment (moins de 30 min),
# lorsqu'elle n'est pas encore rattachee a un thread T3 : elle est alors consideree comme active.
function Test-RecentSession([string]$SessionId) {
  $limit = (Get-Date).AddMinutes(-30)
  [bool](Get-ChildItem (Join-Path $HOME '.claude\projects\*') -Filter "$SessionId.jsonl" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt $limit })
}

# Cette methode permet d'arreter les containers des projets Compose d'une entree (worktrees et 2e instances)
# lorsque tous ses threads sont settled ; renvoie les projets effectivement arretes.
function Stop-EntryStacks($Entry) {
  $slugs = @{ back = $Entry.back; front = $Entry.front }
  foreach ($side in 'back', 'front') {
    # Meme nommage que nop-worktree.ps1 : la 2e instance d'un cote porte le slug de la branche de l'autre cote.
    $branch = if ($slugs[$side]) { $slugs[$side] } else { $slugs[@{ back = 'front'; front = 'back' }[$side]] }
    $project = "nop-$side-$($branch -replace '[^A-Za-z0-9._-]', '-')".ToLower()
    $ids = @(docker ps -q --filter "label=com.docker.compose.project=$project" 2>$null)
    if ($ids.Count -eq 0) { continue }
    if (-not $DryRun) { docker stop @ids | Out-Null }
    $project
  }
}

# Cette methode permet de dire pourquoi un worktree ne peut pas etre supprime sans perte lorsqu'il a du travail non pousse ;
# renvoie $null s'il est sur.
function Get-UnsafeReason([string]$Dir, [string]$Branch, [string]$Main) {
  if (@(git -C $Dir status --porcelain).Count -gt 0) { return 'modifications non commitees' }
  $local = @(git -C $Dir rev-list HEAD --not --remotes)
  # Branche rebasee et force-pushee par l'auteur : les anciennes versions des commits ont un equivalent (meme patch) sur origin.
  if ($local -and (git -C $Dir rev-parse --verify -q "refs/remotes/origin/$Branch")) {
    $alreadyPushed = @(git -C $Dir cherry "origin/$Branch" HEAD | Where-Object { $_ -like '- *' } | ForEach-Object { $_.Substring(2) })
    $local = @($local | Where-Object { $_ -notin $alreadyPushed })
  }
  $unpushed = $local.Count
  if ($unpushed -eq 0) { return $null }
  $repo = (git -C $Main remote get-url origin) -replace '^.*github\.com[:/]', '' -replace '\.git$', ''
  $merged = gh pr list --repo $repo --head $Branch --state merged --json number --jq 'length' 2>$null
  if ([int]$merged -gt 0) { return $null }
  return "$unpushed commit(s) absents d'origin"
}

if (-not (Test-Path $ownersFile)) { return }
# Tache planifiee et lancement manuel peuvent se chevaucher : une seule execution a la fois.
$mutex = New-Object System.Threading.Mutex($false, 'Local\nop-worktree-cleanup')
if (-not $mutex.WaitOne(0)) { return }
try {
  $owners = @(Get-Content $ownersFile -Raw | ConvertFrom-Json)
  foreach ($entry in $owners) {
    $label = (@($entry.back, $entry.front) | Where-Object { $_ } | Select-Object -Unique) -join ' / '

    # Threads connus, completes par les sessions resolues depuis (session lancee avant la creation de son thread).
    $threads = @($entry.threads | Where-Object { $_ })
    $recentUnresolved = $false
    foreach ($s in $entry.sessions) {
      $t = python -I $helper thread-of $s 2>$null
      if ($t) { if ($t -notin $threads) { $threads += $t } }
      elseif (Test-RecentSession $s) { $recentUnresolved = $true }
    }
    # Thread T3 tout juste lance : le lien session -> thread n'est ecrit qu'apres son premier tour.
    if ($recentUnresolved) { continue }
    if (-not $threads) { continue }  # session hors T3 (terminal) : jamais supprime automatiquement
    $states = python -I $helper status @threads | ConvertFrom-Json
    if (@($threads | Where-Object { $states.$_ -eq 'active' })) { continue }

    # Palier 1 : au moins un thread settled (pas encore archive) -> arret des containers seulement.
    if (@($threads | Where-Object { $states.$_ -eq 'settled' })) {
      $stopped = @(Stop-EntryStacks $entry)
      if ($stopped) {
        if ($DryRun) { Write-Host "A ARRETER $label : $($stopped -join ', ')" } else { Write-Log "ARRETE $label (threads settled) : $($stopped -join ', ')" }
      }
      continue
    }

    $existing = foreach ($side in 'back', 'front') {
      $branch = $entry.$side
      if (-not $branch) { continue }
      $dir = Join-Path $root "worktrees\Outil-NOP-$($repos[$side].Name)-$($branch -replace '[^A-Za-z0-9._-]', '-')"
      if (Test-Path $dir) { [pscustomobject]@{ Dir = $dir; Branch = $branch; Main = $repos[$side].Main } }
    }
    $reasons = foreach ($w in $existing) { $r = Get-UnsafeReason $w.Dir $w.Branch $w.Main; if ($r) { "$(Split-Path $w.Dir -Leaf) : $r" } }
    if ($reasons) { Write-Log "GARDE $label (threads termines) : $($reasons -join ' ; ')" -Once; continue }

    # Splatting par table : un tableau passerait '-BackBranch' comme argument positionnel a un script.
    $removeArgs = @{ Remove = $true }
    if ($entry.back -and $entry.back -eq $entry.front) { $removeArgs.Branch = $entry.back } else {
      if ($entry.back) { $removeArgs.BackBranch = $entry.back }
      if ($entry.front) { $removeArgs.FrontBranch = $entry.front }
    }
    if ($DryRun) { Write-Host "A SUPPRIMER $label : nop-worktree.ps1 $(($removeArgs.GetEnumerator() | ForEach-Object { "-$($_.Key) $($_.Value)" }) -join ' ')"; continue }
    try {
      & (Join-Path $PSScriptRoot 'nop-worktree.ps1') @removeArgs *>&1 | Out-Null
      Write-Log "SUPPRIME $label (threads archives/supprimes : $($threads.Count))"
    } catch {
      Write-Log "ECHEC $label : $($_.Exception.Message)" -Once
    }
  }
} finally { $mutex.ReleaseMutex() }
