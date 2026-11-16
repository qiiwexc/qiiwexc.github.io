function Read-TextFile {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path,
        [Switch]$AsList
    )

    $Content = Get-Content $Path -Raw:(-not $AsList) -Encoding UTF8

    # Bytes that are not UTF-8 come back as U+FFFD, the replacement character. A file saved in a code page would
    # otherwise reach the build's output with each of its non-ASCII characters replaced, and nothing would notice
    if ((-join $Content).IndexOf([Char]0xFFFD) -ge 0) {
        throw "'$Path' is not UTF-8: save it as UTF-8, with a byte order mark if it is a PowerShell script"
    }

    return $Content
}
