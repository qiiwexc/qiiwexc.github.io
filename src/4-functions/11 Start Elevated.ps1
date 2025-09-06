Function Start-Elevated {
    if (!$IS_ELEVATED) {
        Add-Log $INF 'Requesting administrator privileges...'

        try {
            Start-Script -Elevated -BypassExecutionPolicy -WorkingDirectory:$PATH_CURRENT_DIR -HideConsole:$HideConsole $MyInvocation.ScriptName
        } catch [Exception] {
            Add-Log $ERR "Failed to gain administrator privileges: $($_.Exception.Message)"
            Return
        }

        Exit-Script
    }
}
