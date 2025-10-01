function Remove-Directory {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$DirectoryPath,
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
