function Remove-Directory {
    param(
        [Parameter(Position = 0, Mandatory)][String]$DirectoryPath,
        [Switch]$Silent
    )

    if (Test-Path $DirectoryPath) {
        if ($Silent) {
            Remove-Item -Force -Recurse $DirectoryPath -ErrorAction Ignore
        } else {
            Remove-Item -Force -Recurse $DirectoryPath
        }
    }
}
