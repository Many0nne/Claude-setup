<#
.SYNOPSIS
  Ouvre une session Claude interactive dans un nouvel onglet Windows Terminal (ou une nouvelle fenetre PowerShell a defaut),
  avec pour premier message la lecture du brief.

.EXAMPLE
  .\launch.ps1 -Dir C:\projets\NOP -Brief C:\projets\NOP\worktrees\.briefs\feature-x.md -Title feature-x
#>
param(
  [Parameter(Mandatory)][string]$Dir,
  [Parameter(Mandatory)][string]$Brief,
  [Parameter(Mandatory)][string]$Title
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Dir)) { throw "Dossier introuvable : $Dir" }
if (-not (Test-Path $Brief)) { throw "Brief introuvable : $Brief" }

# Pas de ';' dans la commande : Windows Terminal l'interprete comme separateur de sous-commandes.
$prompt = "Lis le brief $Brief puis execute-le en respectant toutes ses consignes." -replace "'", "''"
$command = "claude '$prompt'"

if (Get-Command wt -ErrorAction SilentlyContinue) {
  wt -w 0 new-tab --title $Title -d $Dir pwsh -NoExit -Command $command
  Write-Host "Onglet '$Title' ouvert dans Windows Terminal ($Dir)."
} else {
  Start-Process pwsh -WorkingDirectory $Dir -ArgumentList '-NoExit', '-Command', "`$Host.UI.RawUI.WindowTitle = '$Title'; $command"
  Write-Host "Windows Terminal absent : fenetre PowerShell '$Title' ouverte ($Dir)."
}
