function Read-TextFile {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path,
        [Switch]$AsList
    )

    return Get-Content $Path -Raw:(-not $AsList) -Encoding UTF8
}
