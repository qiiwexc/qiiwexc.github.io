function Remove-File {
    param(
        [Parameter(Position = 0, Mandatory)][String]$FilePath,
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
