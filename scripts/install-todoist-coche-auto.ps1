<#
.SYNOPSIS
  Installe (ou met a jour) la tache planifiee Windows "Todoist coche auto" qui lance todoist-coche-auto.ps1
  toutes les 10 minutes et a l'ouverture de session, sans fenetre (conhost --headless).
  Idempotent ; -Uninstall retire la tache.

.EXAMPLE
  & "$HOME\.claude\scripts\install-todoist-coche-auto.ps1"
  & "$HOME\.claude\scripts\install-todoist-coche-auto.ps1" -Uninstall
#>
param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'
$taskName = 'Todoist coche auto'

if ($Uninstall) {
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
  Write-Host "Tache '$taskName' retiree."
  return
}

$script = Join-Path $PSScriptRoot 'todoist-coche-auto.ps1'
$pwsh = (Get-Command pwsh).Source
# conhost --headless : pas de fenetre qui clignote toutes les 10 minutes.
$action = New-ScheduledTaskAction -Execute 'conhost.exe' -Argument "--headless `"$pwsh`" -NoProfile -NonInteractive -File `"$script`""
$triggers = @(
  New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
  New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10)
)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable `
  -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings `
  -Description 'Coche les taches Todoist dont toutes les PR GitHub citees sont mergees.' -Force | Out-Null
Write-Host "Tache '$taskName' installee (toutes les 10 minutes et a l'ouverture de session)."
