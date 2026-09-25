function Expand-WindowsDebloat {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ZipPath,
        [Parameter(Position = 1, Mandatory)][String]$ToolPath
    )

    Write-ActivityProgress 65 "Extracting '$ZipPath'..."

    # Win11Debloat keeps its logs and its registry backups, which its window restores changes from, in
    # its own folder: they outlive its files, which are replaced with the checked archive every time
    Set-Variable -Option Constant KeptFolders ([String[]]@('Backups', 'Logs'))

    if (Test-Path -LiteralPath $ToolPath) {
        Get-ChildItem -LiteralPath $ToolPath -Force -ErrorAction Stop |
            Where-Object { $_.Name -notin $KeptFolders } |
            Remove-Item -Recurse -Force -ErrorAction Stop
    }

    Set-Variable -Option Constant StagingPath ([String]"$PATH_APP_DIR\Win11Debloat")

    Remove-Directory $StagingPath
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $StagingPath -Force -ErrorAction Stop

    Write-ActivityProgress 75

    # A tag's source archive holds a single folder, named after the repository and the tag
    Set-Variable -Option Constant Content ([IO.FileSystemInfo[]]@(Get-ChildItem -LiteralPath $StagingPath -Force -ErrorAction Stop))
    if ($Content.Count -ne 1 -or -not $Content[0].PSIsContainer) {
        throw "Unexpected content in '$ZipPath': expected a single folder"
    }

    New-Directory $ToolPath
    Get-ChildItem -LiteralPath $Content[0].FullName -Force -ErrorAction Stop | Move-Item -Destination $ToolPath -Force -ErrorAction Stop
    Remove-Directory $StagingPath -Silent

    Set-Variable -Option Constant ScriptPath ([String]"$ToolPath\Win11Debloat.ps1")
    if (-not (Test-Path -LiteralPath $ScriptPath)) {
        throw "Win11Debloat.ps1 not found in '$ZipPath'"
    }

    Write-ActivityProgress 80

    return $ScriptPath
}
