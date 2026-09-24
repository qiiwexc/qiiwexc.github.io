function Start-WinUtil {
    Write-LogInfo 'Starting WinUtil utility...'

    try {
        # The release pinned in dependencies.json, checked against its recorded checksum, rather than
        # whatever the project's website serves at the moment of the click
        Set-Variable -Option Constant ScriptPath ([String](Start-Download '{URL_WINUTIL}' -Sha256 '{SHA256_WINUTIL}' -Temp))

        # Read as UTF-8, as the script has no byte order mark and Windows PowerShell would read it as ANSI.
        # The app is elevated, so WinUtil does not relaunch itself, which would fetch its latest release
        Invoke-CustomCommand "& ([ScriptBlock]::Create((Get-Content -Raw -Encoding UTF8 -LiteralPath '$($ScriptPath.Replace("'", "''"))')))"

        Out-Success
    } catch {
        Out-Failure "Failed to start WinUtil utility: $_"
    }
}
