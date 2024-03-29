Function Start-Elevated {
    if (!$IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try { Start-ExternalProcess -Elevated "$($MyInvocation.ScriptName)$(if ($HIDE_CONSOLE) {' -HideConsole'})" }
        catch [Exception] { Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"; Return }

        Exit-Script
    }
}
