param()
$json = $input | Out-String | ConvertFrom-Json
$sid = $json.session_id
$fp = $json.tool_input.file_path
$cf = "$env:USERPROFILE\.claude\context-cache\cache.json"

if (-not $sid -or -not $fp) { exit 0 }

$cache = if (Test-Path $cf) { Get-Content $cf -Raw | ConvertFrom-Json } else { [PSCustomObject]@{} }

if (-not ($cache | Get-Member -Name $sid -MemberType NoteProperty)) {
    $cache | Add-Member -NotePropertyName $sid -NotePropertyValue @()
}

if ($cache.$sid -notcontains $fp) {
    $cache.$sid += $fp
}

$cache | ConvertTo-Json -Compress | Set-Content $cf
