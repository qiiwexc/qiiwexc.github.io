function Write-VersionFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Version,
        [String][Parameter(Position = 1, Mandatory)]$VersionFile
    )

    Write-LogInfo 'Writing version file...'

    Write-File $VersionFile $Version

    Out-Success
}
