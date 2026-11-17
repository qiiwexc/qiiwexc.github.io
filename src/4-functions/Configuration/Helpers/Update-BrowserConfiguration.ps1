# Fails by throwing, so that the caller reports the failure once and does not go on to report the browser done
function Update-BrowserConfiguration {
    param(
        [Parameter(Position = 0, Mandatory)][String]$AppName,
        [Parameter(Position = 1, Mandatory)][String]$ProcessName,
        [Parameter(Position = 2, Mandatory)][String]$Content,
        [Parameter(Position = 3, Mandatory)][String]$Path
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Write-LogInfo "Writing '$AppName' configuration to '$Path'..." $LogIndentLevel

    Stop-ProcessIfRunning $ProcessName

    if (-not (Test-Path $Path)) {
        Write-LogInfo "'$AppName' profile does not exist. Launching '$AppName' to create it" $LogIndentLevel

        Set-Variable -Option Constant Executable ([String](Get-AppExecutablePath "$ProcessName.exe"))

        if (-not $Executable) {
            throw "'$AppName' is not installed"
        }

        try {
            # Through the shell, so that the browser does not run elevated
            Start-FromShell $Executable
        } catch {
            throw "Couldn't start '$AppName': $_"
        }

        for ([Int]$i = 0; $i -lt 5; $i++) {
            Start-Sleep -Seconds 10
            if (Test-Path $Path) {
                break
            }
        }

        # The browser rewrites its profile files on exit, which would discard the changes below
        Stop-ProcessIfRunning $ProcessName
    }

    Set-Variable -Option Constant CurrentConfig ([PSCustomObject](Get-Content $Path -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop))
    Set-Variable -Option Constant ExtendConfig ([PSCustomObject]($Content | ConvertFrom-Json -ErrorAction Stop))

    Set-Variable -Option Constant UpdatedConfig ([String](Merge-JsonObject $CurrentConfig $ExtendConfig -ErrorAction Stop | ConvertTo-Json -Depth 100 -Compress -ErrorAction Stop))

    # Merged rather than replaced, but rewritten whole: a profile the browser cannot read loses every setting in it
    Backup-File $Path ($LogIndentLevel + 1)

    Set-Content $Path $UpdatedConfig -Encoding UTF8 -NoNewline -ErrorAction Stop

    Out-Success $LogIndentLevel
}
