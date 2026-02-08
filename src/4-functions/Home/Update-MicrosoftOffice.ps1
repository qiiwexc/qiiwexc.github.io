function Update-MicrosoftOffice {
    try {
        Write-LogInfo 'Starting Microsoft Office update...'

        if ($OFFICE_INSTALL_TYPE -ne 'C2R') {
            Write-LogWarning 'Microsoft Office update is only supported for Click-to-Run installations'
            return
        }

        if (-not (Test-Path $PATH_OFFICE_C2R_CLIENT_EXE)) {
            Write-LogWarning "Microsoft Office Click-to-Run client executable not found at '$PATH_OFFICE_C2R_CLIENT_EXE'"
            return
        }

        Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user' -ErrorAction Stop

        Out-Success
    } catch {
        Out-Failure "Failed to update Microsoft Office: $_"
    }
}
