function Start-Elevated {
    if (-not $IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try { Start-Process 'powershell' "$($MyInvocation.ScriptName)$(if ($HIDE_CONSOLE) {' -HideConsole'})" -Verb RunAs }
        catch [Exception] { Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"; Return }

        Exit-Script
    }
}
