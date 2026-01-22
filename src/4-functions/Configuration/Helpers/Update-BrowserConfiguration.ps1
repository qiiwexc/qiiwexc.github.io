function Update-BrowserConfiguration {
    param(
        [String][Parameter(Position = 0, Mandatory)]$AppName,
        [String][Parameter(Position = 1, Mandatory)]$ProcessName,
        [String][Parameter(Position = 2, Mandatory)]$Content,
        [String][Parameter(Position = 3, Mandatory)]$Path
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    try {
        Write-LogInfo "Writing '$AppName' configuration to '$Path'..." $LogIndentLevel

        Stop-ProcessIfRunning $ProcessName

        if (-not (Test-Path $Path)) {
            Write-LogInfo "'$AppName' profile does not exist. Launching '$AppName' to create it" $LogIndentLevel

            try {
                Start-Process $ProcessName -ErrorAction Stop
            } catch {
                Out-Failure "Couldn't start '$AppName': $_" $LogIndentLevel
                throw $_
            }

            for ([Int]$i = 0; $i -lt 5; $i++) {
                Start-Sleep -Seconds 10
                if (Test-Path $Path) {
                    break
                }
            }
        }

        Set-Variable -Option Constant CurrentConfig ([PSCustomObject](Get-Content $Path -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop))
        Set-Variable -Option Constant ExtendConfig ([PSCustomObject]($Content | ConvertFrom-Json -ErrorAction Stop))

        Set-Variable -Option Constant UpdatedConfig ([String](Merge-JsonObject $CurrentConfig $ExtendConfig -ErrorAction Stop | ConvertTo-Json -Depth 100 -Compress -ErrorAction Stop))

        $UpdatedConfig | Set-Content $Path -Encoding UTF8 -NoNewline -ErrorAction Stop

        Out-Success $LogIndentLevel
    } catch {
        Out-Failure "Failed to update '$AppName' configuration: $_" $LogIndentLevel
    }
}
