Function Start-Elevated {
    if (!$IS_ELEVATED) {
        Write-Log $INF 'Requesting administrator privileges...'

        try {
            Start-Script -Elevated -BypassExecutionPolicy -WorkingDirectory:$PATH_CURRENT_DIR -HideConsole:$HideConsole $MyInvocation.ScriptName
        } catch [Exception] {
            Write-ExceptionLog $_ 'Failed to gain administrator privileges'
            Return
        }

        Exit-Script
    }
}
