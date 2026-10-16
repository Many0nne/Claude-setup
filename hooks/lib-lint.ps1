# Fonctions communes aux hooks lint-on-edit.ps1 et stop-validate.ps1 (dot-source).
# Detection par depot : ruff si le pyproject le configure, ESLint si eslint.config.* et node_modules existent.

# Cette methode permet de retrouver la racine git d'un fichier lorsqu'on doit lancer un linter avec la config du depot.
function Get-RepoRoot([string]$File) {
  $dir = Split-Path $File -Parent
  if (-not (Test-Path $dir)) { return $null }
  $root = git -C $dir rev-parse --show-toplevel 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $root) { return $null }
  return ($root -replace '/', '\')
}

# Cette methode permet de construire la commande ruff (version epinglee du pre-commit via uvx, sinon ruff du PATH)
# lorsque le depot configure ruff ; renvoie $null sinon.
function Get-RuffCommand([string]$Root) {
  $pyproject = Join-Path $Root 'pyproject.toml'
  if (-not ((Test-Path $pyproject) -and (Select-String -Path $pyproject -Pattern '^\[tool\.ruff' -Quiet))) { return $null }
  if (Get-Command uvx -ErrorAction SilentlyContinue) {
    $version = $null
    $precommit = Join-Path $Root '.pre-commit-config.yaml'
    if (Test-Path $precommit) {
      $lines = Get-Content $precommit
      $idx = ($lines | Select-String -Pattern 'ruff-pre-commit' | Select-Object -First 1).LineNumber
      if ($idx) {
        $rev = $lines[$idx..($idx + 3)] | Select-String -Pattern 'rev:\s*v?([\d.]+)' | Select-Object -First 1
        if ($rev) { $version = $rev.Matches[0].Groups[1].Value }
      }
    }
    $pkg = if ($version) { "ruff@$version" } else { 'ruff' }
    return @('uvx', $pkg)
  }
  if (Get-Command ruff -ErrorAction SilentlyContinue) { return @('ruff') }
  return $null
}

# Cette methode permet de lancer ruff check (et format --check si demande) sur des fichiers lorsqu'ils sont dans un depot equipe ;
# renvoie le texte des erreurs, vide si tout passe.
function Invoke-Ruff([string]$Root, [string[]]$Files, [switch]$Format) {
  $ruff = Get-RuffCommand $Root
  if (-not $ruff) { return '' }
  $exe = $ruff[0]; $pre = @($ruff | Select-Object -Skip 1)
  Push-Location $Root
  try {
    $out = & $exe @pre check --output-format concise --no-cache @Files 2>&1 | Out-String
    $errors = if ($LASTEXITCODE -ne 0) { $out.Trim() } else { '' }
    if ($Format) {
      $fmt = & $exe @pre format --check @Files 2>&1 | Out-String
      if ($LASTEXITCODE -ne 0) { $errors = ($errors + "`n" + $fmt.Trim() + "`n-> lancer ruff format sur ces fichiers.").Trim() }
    }
    return $errors
  } finally { Pop-Location }
}

# Cette methode permet de lancer ESLint (sans --fix) sur des fichiers lorsque le depot a une config et ses node_modules ;
# renvoie le texte des erreurs, vide si tout passe ou si ESLint est indisponible.
function Invoke-Eslint([string]$Root, [string[]]$Files) {
  $hasConfig = Get-ChildItem -Path $Root -Filter 'eslint.config.*' -File -ErrorAction SilentlyContinue
  $eslint = Join-Path $Root 'node_modules\.bin\eslint.cmd'
  if (-not $hasConfig) { return '' }
  if (-not (Test-Path $eslint)) { return "ESLint non lance dans $Root : node_modules absent (yarn install a faire dans ce worktree)." }
  Push-Location $Root
  try {
    $out = & $eslint @Files 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { return $out.Trim() }
    return ''
  } finally { Pop-Location }
}
