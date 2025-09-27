function Update-JsonFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AppName,
        [String][Parameter(Position = 1, Mandatory = $True)]$ProcessName,
        [String][Parameter(Position = 2, Mandatory = $True)]$Content,
        [String][Parameter(Position = 3, Mandatory = $True)]$Path
    )

    Write-LogInfo "Writing $AppName configuration to '$Path'..."

    Stop-Process -Name $ProcessName -ErrorAction SilentlyContinue

    New-Item -ItemType Directory (Split-Path -Parent $Path) -ErrorAction SilentlyContinue

    if (Test-Path $Path) {
        Set-Variable -Option Constant CurrentConfig (Get-Content $Path -Raw | ConvertFrom-Json)
        Set-Variable -Option Constant PatchConfig ($Content | ConvertFrom-Json)

        Set-Variable -Option Constant UpdatedConfig (Merge-JsonObjects $CurrentConfig $PatchConfig | ConvertTo-Json -Depth 100 -Compress)

        $UpdatedConfig | Out-File $Path -Encoding UTF8
    } else {
        Write-LogInfo "'$Path' does not exist. Creating new file..."
        $Content | Out-File $Path
    }

    Out-Success
}
