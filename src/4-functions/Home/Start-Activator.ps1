function Start-Activator {
    param(
        [Switch]$ActivateWindows,
        [Switch]$ActivateOffice
    )

    try {
        Write-LogInfo 'Starting MAS activator...'

        # This app and the project's own launcher both run MAS as a copy named MAS_<GUID>.cmd in a temp folder
        if (Find-RunningScript '\Temp\MAS_') {
            Write-LogWarning 'MAS activator is already running'
            return
        }

        if (-not (Test-NetworkConnection)) {
            return
        }

        [String]$Params = ''

        if ($ActivateWindows) {
            $Params += ' /HWID'
        }

        if ($ActivateOffice) {
            $Params += ' /Ohook'
        }

        # The release pinned in dependencies.json, checked against its recorded checksum, rather than
        # whatever the project's launcher serves at the moment of the click
        Set-Variable -Option Constant DownloadPath ([String](Start-Download '{URL_MICROSOFT_ACTIVATION_SCRIPTS}' -Sha256 '{SHA256_MICROSOFT_ACTIVATION_SCRIPTS}' -Temp))

        # MAS refuses to run from a folder inside the user's temp folder, so it runs from the system one, as
        # the project's launcher does for an administrator. A standard user can neither change a file an
        # administrator created there nor plant one under a name they cannot guess, so the copy that runs
        # is the one checked
        Set-Variable -Option Constant ScriptPath ([String]"$env:SystemRoot\Temp\MAS_$([Guid]::NewGuid()).cmd")
        Copy-Item -LiteralPath $DownloadPath -Destination $ScriptPath -ErrorAction Stop
        Test-FileChecksum $ScriptPath '{SHA256_MICROSOFT_ACTIVATION_SCRIPTS}'

        # '-el' is what the project's launcher passes too: it keeps MAS from relaunching itself to elevate
        Start-Process "$PATH_SYSTEM_32\cmd.exe" "/c `"`"$ScriptPath`" -el$Params`"" -ErrorAction Stop

        Out-Success
    } catch {
        Out-Failure "Failed to start MAS activator: $_"
    }
}
