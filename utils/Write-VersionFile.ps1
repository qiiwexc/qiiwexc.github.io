function Write-VersionFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Version,
        [String][Parameter(Position = 1, Mandatory = $True)]$VersionFile
    )

    Write-LogInfo 'Writing version file...'

    $Version | Out-File $VersionFile -Encoding ASCII

    Out-Success
}
