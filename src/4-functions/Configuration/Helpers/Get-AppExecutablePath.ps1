function Get-AppExecutablePath {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ExecutableName
    )

    # Where Windows looks up an application started by its name alone, a per-user installation first.
    # The key is shared between the 64-bit and 32-bit registry views
    foreach ($Root in @('HKCU:', 'HKLM:')) {
        [String]$Key = "$Root\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$ExecutableName"

        if (Test-Path -LiteralPath $Key) {
            [String]$Path = ([String](Get-Item -LiteralPath $Key -ErrorAction Stop).GetValue('')).Trim('"')

            # An uninstaller can leave the key behind
            if ($Path -and (Test-Path -LiteralPath $Path -PathType Leaf)) {
                return $Path
            }
        }
    }

    return ''
}
