Function Write-ConfigurationFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Path,
        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
        [String][Parameter(Position = 3)]$ProcessName = $AppName
    )

    Add-Log $INF "Writing $AppName configuration to '$Path'..."

    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue

    New-Item -ItemType Directory $(Split-Path -Parent $Path)
    Set-Content $Path $Content

    Out-Success
}


Function Update-JsonFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Path,
        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
        [String][Parameter(Position = 3)]$ProcessName = $AppName
    )

    Add-Log $INF "Writing $AppName configuration to '$Path'..."

    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue

    New-Item -ItemType Directory $(Split-Path -Parent $Path)

    $CurrentConfig = Get-Content $Path -Raw | ConvertFrom-Json
    $PatchConfig = $Content | ConvertFrom-Json

    $UpdatedConfig = Merge-JsonObjects $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress

    Set-Content $Path $UpdatedConfig

    Out-Success
}


Function Import-RegistryConfiguration {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Content
    )

    Add-Log $INF "Importing $AppName configuration into registry..."

    Set-Variable -Option Constant RegFilePath "$PATH_TEMP_DIR\$AppName.reg"
    Set-Content $RegFilePath $Content

    try {
        Start-Process -Verb RunAs -Wait 'regedit' "/s $RegFilePath"
    } catch [Exception] {
        Add-Log $ERR "Failed to import file: $($_.Exception.Message)"
        Return
    }

    Out-Success
}
