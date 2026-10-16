# Hook PostToolUse (Edit|Write|MultiEdit) : ruff check sur le fichier Python qui vient d'etre modifie.
# Exit 2 = l'erreur est renvoyee a Claude, qui corrige tout de suite (RUF001, imports, etc.). ESLint est trop lent ici : voir stop-validate.ps1.

$ErrorActionPreference = 'SilentlyContinue'

$payload = $null
try { $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json } catch { exit 0 }
$file = [string]$payload.tool_input.file_path
if (-not $file -or $file -notmatch '\.py$' -or -not (Test-Path $file)) { exit 0 }

. "$PSScriptRoot\lib-lint.ps1"

$root = Get-RepoRoot $file
if (-not $root) { exit 0 }
$errors = Invoke-Ruff $root @($file)
if ($errors) {
  [Console]::Error.WriteLine("ruff signale des erreurs dans $file (le pre-commit les refusera) :`n$errors")
  exit 2
}
exit 0
