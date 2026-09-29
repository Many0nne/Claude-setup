$raw = [Console]::In.ReadToEnd()
$json = $raw | ConvertFrom-Json
$command = $json.tool_input.command

if (-not $command) { exit 0 }

# Commands that should go through rtk but don't
$patterns = @(
    '^git ',
    '^gh ',
    '^tsc(\s|$)',
    '^pnpm ',
    '^npm run',
    '^npx ',
    '^vitest(\s|$)',
    '^playwright(\s|$)',
    '^cargo ',
    '^docker ps',
    '^docker images',
    '^docker logs',
    '^kubectl ',
    '^prettier ',
    '^next build',
    '^ruff ',
    '^eslint '
)

if ($command -match '^rtk ') { exit 0 }

foreach ($pattern in $patterns) {
    if ($command -match $pattern) {
        $firstWord = ($command -split '\s+')[0]
        Write-Host "RTK enforcer: prefixe la commande avec rtk -> ``rtk $command``"
        exit 2
    }
}

exit 0
