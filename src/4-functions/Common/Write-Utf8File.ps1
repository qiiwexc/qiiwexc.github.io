function Write-Utf8File {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path,
        [Parameter(Position = 1, Mandatory)][AllowEmptyString()][String]$Content
    )

    # UTF-8 without a byte order mark, which not every tool these files configure expects. Set-Content writes the ANSI
    # code page unless told otherwise, which turns a character outside it into '?', and its UTF8 encoding adds the mark.
    # Content in ASCII comes out byte for byte the same either way
    Set-Content -LiteralPath $Path -Value ([Text.UTF8Encoding]::new($False).GetBytes($Content)) -Encoding Byte -ErrorAction Stop
}
