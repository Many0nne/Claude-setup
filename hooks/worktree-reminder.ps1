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
if ($claudeMds | Where-Object { Select-String -Path $_ -Pattern 'worktree' -Quiet }) { exit 0 }
if (Get-ChildItem -Path (Join-Path $root 'scripts') -Filter '*worktree*' -File) { exit 0 }

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
