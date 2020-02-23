Function Start-Elevated {
    if (-not $IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try { Start-Process -Verb RunAs 'PowerShell' "$($MyInvocation.ScriptName)$(if ($HIDE_CONSOLE) {' -HideConsole'})" }
        catch [Exception] { Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"; Return }

        Exit-Script
    }
}
