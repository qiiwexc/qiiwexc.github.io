function Read-JsonFile {
    param(
        [ValidateNotNullOrEmpty()][String][Parameter(Position = 0, Mandatory)]$Path
    )

    return Read-TextFile $Path | ConvertFrom-Json
}
