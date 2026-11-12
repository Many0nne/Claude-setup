# Fonctions communes aux hooks lint-on-edit.ps1 et stop-validate.ps1 (dot-source).
# Detection par depot : ruff si le pyproject le configure, ESLint si eslint.config.* et node_modules existent.
# Luau : tools/check.sh du depot s'il existe (Invoke-LuauCheck).

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

# Cette methode permet de lancer tools/check.sh (lint, format, types, tests) lorsque des fichiers .luau d'un depot qui l'a
# ont ete modifies ; saute le lancement si ces fichiers n'ont pas bouge depuis le dernier passage reussi. Renvoie la sortie en cas d'echec.
function Invoke-LuauCheck([string]$Root, [string[]]$Files) {
  if (-not (Test-Path (Join-Path $Root 'tools\check.sh'))) { return '' }
  $signature = ($Files | Sort-Object | ForEach-Object { "$_|$((Get-Item $_).LastWriteTimeUtc.Ticks)" }) -join ';'
  $key = [Convert]::ToHexString([Security.Cryptography.SHA1]::HashData([Text.Encoding]::UTF8.GetBytes($Root.ToLower())))
  $cache = Join-Path ([IO.Path]::GetTempPath()) "claude-hooks\luau-check-$key.txt"
  if ((Test-Path $cache) -and (Get-Content $cache -Raw).Trim() -eq $signature) { return '' }
  # Bash de Git : celui du PATH peut etre le lanceur WSL.
  $bash = Join-Path $env:ProgramFiles 'Git\bin\bash.exe'
  if (-not (Test-Path $bash)) { $bash = 'bash' }
  Push-Location $Root
  try {
    $lines = @(& $bash tools/check.sh 2>&1 | ForEach-Object { "$_" })
    $failed = $LASTEXITCODE -ne 0
  } finally { Pop-Location }
  if (-not $failed) {
    New-Item -ItemType Directory -Force (Split-Path $cache) | Out-Null
    Set-Content -Path $cache -Value $signature
    return ''
  }
  $max = 150
  $out = if ($lines.Count -gt $max) { "(... $($lines.Count - $max) premieres lignes omises)`n" + ($lines[-$max..-1] -join "`n") } else { $lines -join "`n" }
  return "bash tools/check.sh echoue dans $Root (sortie complete, sans filtre) :`n$out"
}

# Cette methode permet de trouver, parmi les services Docker Compose demarres du depot, celui qui contient ESLint
# lorsque les node_modules ne sont installes que dans le conteneur (worktrees NOP) ; renvoie son nom, vide sinon.
function Find-EslintService([string]$Root) {
  $composeFiles = 'compose.yaml', 'compose.yml', 'docker-compose.yml', 'docker-compose.yaml'
  if (-not ($composeFiles | Where-Object { Test-Path (Join-Path $Root $_) })) { return '' }
  Push-Location $Root
  try {
    foreach ($svc in @(docker compose ps --services --status running 2>$null)) {
      docker compose exec -T $svc sh -c 'test -x node_modules/.bin/eslint' 2>$null
      if ($LASTEXITCODE -eq 0) { return $svc }
    }
    return ''
  } finally { Pop-Location }
}

# Cette methode permet de lancer ESLint dans le conteneur `$Service` sur des fichiers du depot lorsque l'hote n'a pas
# de node_modules ; les chemins sont passes relatifs a la racine, montee comme repertoire de travail du conteneur.
function Invoke-EslintDocker([string]$Root, [string]$Service, [string[]]$Files) {
  $rootFull = (Resolve-Path $Root).Path.TrimEnd('\') + '\'
  $relatifs = @($Files | ForEach-Object { (Resolve-Path $_).Path.Replace($rootFull, '').Replace('\', '/') })
  Push-Location $Root
  try {
    $out = docker compose exec -T $Service node_modules/.bin/eslint @relatifs 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { return $out.Trim() }
    return ''
  } finally { Pop-Location }
}

# Cette methode permet de lancer ESLint (sans --fix) sur des fichiers lorsque le depot a une config, avec ses node_modules
# locaux, sinon dans un conteneur Compose demarre ; renvoie le texte des erreurs, vide si tout passe.
function Invoke-Eslint([string]$Root, [string[]]$Files) {
  $hasConfig = Get-ChildItem -Path $Root -Filter 'eslint.config.*' -File -ErrorAction SilentlyContinue
  $eslint = Join-Path $Root 'node_modules\.bin\eslint.cmd'
  if (-not $hasConfig) { return '' }
  if (-not (Test-Path $eslint)) {
    $service = Find-EslintService $Root
    if ($service) { return Invoke-EslintDocker $Root $service $Files }
    return "ESLint non lance dans $Root : ni node_modules local ni conteneur Compose demarre avec ESLint (demarrer la stack du worktree ou yarn install)."
  }
  Push-Location $Root
  try {
    $out = & $eslint @Files 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { return $out.Trim() }
    return ''
  } finally { Pop-Location }
}
