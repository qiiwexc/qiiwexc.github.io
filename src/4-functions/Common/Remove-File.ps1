function Remove-File {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$FilePath,
        [Switch]$Silent
    )

    if (Test-Path $FilePath) {
        if ($Silent) {
            Remove-Item -Force $FilePath -ErrorAction Ignore
        } else {
            Remove-Item -Force $FilePath
        }
    }
}
