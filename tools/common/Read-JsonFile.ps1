function Read-JsonFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Path
    )

    return Read-TextFile $Path | ConvertFrom-Json
}
