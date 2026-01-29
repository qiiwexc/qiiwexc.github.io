function Read-TextFile {
    param(
        [ValidateNotNullOrEmpty()][String][Parameter(Position = 0, Mandatory)]$Path,
        [Switch]$AsList
    )

    return Get-Content $Path -Raw:(-not $AsList) -Encoding UTF8
}
