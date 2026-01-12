function Update-MicrosoftOffice {
    Write-LogInfo 'Starting Microsoft Office update...'

    try {
        Start-Process $PATH_OFFICE_C2R_CLIENT_EXE '/update user'
        Out-Success
    } catch [Exception] {
        Write-LogException $_ 'Failed to update Microsoft Office'
    }
}
