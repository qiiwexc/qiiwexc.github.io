function Update-JsonFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$ProcessName,
        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
        [String][Parameter(Position = 3, Mandatory = $True)]$Path
    )

    Set-Variable -Option Constant LogIndentLevel 2

    Stop-ProcessIfRunning $ProcessName

    Write-LogInfo "Writing $AppName configuration to '$Path'..." $LogIndentLevel

    if (-not (Test-Path $Path)) {
        Write-LogInfo "'$AppName' profile does not exist. Launching '$AppName' to create it" $LogIndentLevel

        try {
            Start-Process $ProcessName -ErrorAction Stop
        } catch [Exception] {
            Write-LogException $_ "Couldn't start '$AppName'" $LogIndentLevel
            return
        }

        for ([Int]$i = 0; $i -lt 5; $i++) {
            Start-Sleep -Seconds 10
            if (Test-Path $Path) {
                break
            }
        }
    }

    Set-Variable -Option Constant CurrentConfig (Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
    Set-Variable -Option Constant PatchConfig ($Content | ConvertFrom-Json)

    Set-Variable -Option Constant UpdatedConfig (Merge-JsonObject $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress)

    $UpdatedConfig | Out-File $Path -Encoding UTF8

    Out-Success $LogIndentLevel
}
