param()
$json = $input | Out-String | ConvertFrom-Json
$sid = $json.session_id
$fp = $json.tool_input.file_path
$cf = "$env:USERPROFILE\.claude\context-cache\cache.json"

if (-not $sid -or -not $fp) { exit 0 }

if (Test-Path $cf) {
    $cache = Get-Content $cf -Raw | ConvertFrom-Json
    if ($cache | Get-Member -Name $sid -MemberType NoteProperty) {
        $cache.$sid = @($cache.$sid | Where-Object { $_ -ne $fp })
        $cache | ConvertTo-Json -Compress | Set-Content $cf
    }
}
