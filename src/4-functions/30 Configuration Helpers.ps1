Function Write-ConfigurationFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Content,
        [String][Parameter(Position = 2, Mandatory = $True)]$Path,
        [String][Parameter(Position = 3)]$ProcessName = $AppName
    )

    Write-Log $INF "Writing $AppName configuration to '$Path'..."

    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue

    New-Item -ItemType Directory (Split-Path -Parent $Path) -ErrorAction SilentlyContinue
    $Content | Out-File $Path

    Out-Success
}


Function Update-JsonFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$ProcessName,
        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
        [String][Parameter(Position = 3, Mandatory = $True)]$Path
    )

    Write-Log $INF "Writing $AppName configuration to '$Path'..."

    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue

    New-Item -ItemType Directory (Split-Path -Parent $Path) -ErrorAction SilentlyContinue

    if (Test-Path $Path) {
        Set-Variable -Option Constant CurrentConfig (Get-Content $Path -Raw | ConvertFrom-Json)
        Set-Variable -Option Constant PatchConfig ($Content | ConvertFrom-Json)

        Set-Variable -Option Constant UpdatedConfig (Merge-JsonObjects $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress)

        $UpdatedConfig | Out-File $Path
    } else {
        Write-Log $INF "'$Path' does not exist. Creating new file..."
        $Content | Out-File $Path
    }

    Out-Success
}


Function Import-RegistryConfiguration {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Content
    )

    Write-Log $INF "Importing $AppName configuration into registry..."

    Set-Variable -Option Constant RegFilePath "$PATH_TEMP_DIR\$AppName.reg"
    $Content | Out-File $RegFilePath

    try {
        Start-Process -Verb RunAs -Wait 'regedit' "/s `"$RegFilePath`""
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to import file into registry'
        Return
    }

    Out-Success
}
