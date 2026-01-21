function Update-MicrosoftOffice {
    Write-LogInfo 'Starting Microsoft Office update...'

    try {
        Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user' -ErrorAction Stop
        Out-Success
    } catch {
        Out-Failure "Failed to update Microsoft Office: $_"
    }
}
