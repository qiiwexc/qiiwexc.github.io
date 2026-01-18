function Write-VersionFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Version,
        [String][Parameter(Position = 1, Mandatory)]$VersionFile
    )

    New-Activity 'Writing version file'

    Write-File $VersionFile $Version

    Write-ActivityCompleted
}
