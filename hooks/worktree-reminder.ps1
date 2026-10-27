# Hook SessionStart : rappelle d'equiper le projet pour la parallelisation par worktrees.
# N'injecte du contexte que si le projet est un depot git (ou contient des depots git) non equipe.

$ErrorActionPreference = 'SilentlyContinue'

$payload = $null
try { $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json } catch {}
$root = if ($payload -and $payload.cwd) { $payload.cwd } else { (Get-Location).Path }

# Cette methode permet de lister le dossier courant et ses sous-dossiers directs lorsqu'on cherche des depots ou des fichiers compose.
function Get-CandidateDir([string]$Dir) {
  @($Dir) + @(Get-ChildItem -Path $Dir -Directory -Force | Where-Object { $_.Name -notmatch '^(\.|node_modules$|worktrees$)' } | ForEach-Object { $_.FullName })
}

$dirs = Get-CandidateDir $root
$isGit = (git -C $root rev-parse --is-inside-work-tree 2>$null) -eq 'true'
if (-not $isGit) { $isGit = [bool]($dirs | Where-Object { Test-Path (Join-Path $_ '.git') }) }
if (-not $isGit) { exit 0 }

# Equipe (ou refus deja note) : un CLAUDE.md du projet ou d'un dossier parent qui parle de worktrees, ou un script dedie.
$ancestors = @()
$cur = Get-Item $root
while ($cur -and $cur.FullName -ne $HOME) { $ancestors += $cur.FullName; $cur = $cur.Parent }
$claudeMds = foreach ($a in $ancestors) {
  @('CLAUDE.md', '.claude\CLAUDE.md', 'CLAUDE.local.md') | ForEach-Object { Join-Path $a $_ } | Where-Object { Test-Path $_ }
}
# Racine du checkout principal (session lancee dans un worktree : ses scripts ne sont pas ceux de la tache planifiee).
$mainRoot = $root
$common = git -C $root rev-parse --path-format=absolute --git-common-dir 2>$null
if ($common) { $mainRoot = Split-Path -Parent $common }

$mentionsWorktree = [bool]($claudeMds | Where-Object { Select-String -Path $_ -Pattern 'worktree' -Quiet })
$hasScript = [bool](Get-ChildItem -Path (Join-Path $mainRoot 'scripts') -Filter '*worktree*' -File)
if ($mentionsWorktree -or $hasScript) {
  # Equipe : verifier que le workflow de tache (CLAUDE.md global) y est en place, sauf refus deja note.
  if ($claudeMds | Where-Object { Select-String -Path $_ -Pattern 'Workflow de t.che : non pertinent' -Quiet }) { exit 0 }
  $missing = @()
  if (-not ($claudeMds | Where-Object { Select-String -Path $_ -Pattern "Workflow d.une t.che" -Quiet })) {
    $missing += "pas de section 'Workflow d'une tache' dans le CLAUDE.md du projet (PR avec Closes #n, merge sur ordre, suppression du worktree au merge de la PR)"
  }
  $cleanup = Get-ChildItem -Path (Join-Path $mainRoot 'scripts') -Filter '*worktree-cleanup*.ps1' -File | Select-Object -First 1
  if (-not $cleanup) {
    $missing += 'pas de script de nettoyage automatique des worktrees (scripts/*worktree-cleanup*.ps1)'
  } elseif (-not (Get-ScheduledTask | Where-Object { $_.Actions.Arguments -like "*$($cleanup.FullName)*" })) {
    $missing += "tache planifiee de nettoyage absente sur ce poste (lancer scripts/install-cleanup-task.ps1)"
  }
  if (-not $missing) { exit 0 }
  $msg = "Workflow de tache incomplet sur ce projet : $($missing -join ' ; '). " +
    "Le rappeler a l'utilisateur en une ligne au debut de ta premiere reponse, sans bloquer sa demande, une seule fois, et proposer d'aligner le projet (skill /setup-worktrees). " +
    "S'il juge ca non pertinent, ajouter la ligne 'Workflow de tache : non pertinent' au CLAUDE.md du projet."
  @{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $msg } } | ConvertTo-Json -Compress
  exit 0
}

$composeNames = 'compose.yaml', 'compose.yml', 'docker-compose.yml', 'docker-compose.yaml'
$hasCompose = [bool]($dirs | Where-Object { $d = $_; $composeNames | Where-Object { Test-Path (Join-Path $d $_) } })

$level = if ($hasCompose) {
  'Le projet utilise Docker compose : il faut une stack isolee par worktree (skill /setup-worktrees).'
} else {
  'Pas de Docker compose detecte : git worktree suffit, une section courte dans CLAUDE.md peut suffire (skill /setup-worktrees).'
}
$msg = "Projet non equipe pour la parallelisation par worktrees. $level " +
  "Le rappeler a l'utilisateur en une ligne au debut de ta premiere reponse, sans bloquer sa demande, une seule fois. " +
  "S'il juge ca non pertinent, ajouter la ligne 'Parallelisation worktrees : non pertinente' au CLAUDE.md du projet."

@{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $msg } } | ConvertTo-Json -Compress
