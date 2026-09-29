param()
$json = $input | Out-String | ConvertFrom-Json
$sid = $json.session_id
$fp = $json.tool_input.file_path
$cf = "$env:USERPROFILE\.claude\context-cache\cache.json"

if (-not $sid -or -not $fp) { exit 0 }

if (Test-Path $cf) {
    $cache = Get-Content $cf -Raw | ConvertFrom-Json
    $files = $cache.$sid
    if ($files -and ($files -contains $fp)) {
        @{
            hookSpecificOutput = @{
                hookEventName           = 'PreToolUse'
                permissionDecision      = 'deny'
                permissionDecisionReason = "File '$fp' was already read this session and is in your context. Do NOT use the Read tool again — reference it from context instead."
            }
        } | ConvertTo-Json -Compress
        exit 0
    }
}
