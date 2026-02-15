function Read-JsonFile {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path
    )

    return Read-TextFile $Path | ConvertFrom-Json
}
