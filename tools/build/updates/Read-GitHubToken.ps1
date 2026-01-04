function Read-GitHubToken {
    param(
        [String][Parameter(Position = 0, Mandatory)]$EnvPath
    )

    Write-LogInfo 'Reading GitHub token'

    Set-Variable -Option Constant EnvContent ([String](Get-Content $EnvPath -Raw -Encoding UTF8))
    Set-Variable -Option Constant Lines ([Collections.Generic.List[String]]($EnvContent -split "`n" | ForEach-Object { $_.Trim() }))

    foreach ($Line in $Lines) {
        if ($Line -match '^GITHUB_TOKEN=(.+)$') {
            Set-Variable -Option Constant Value ([String]$Matches[1].Trim())

            if (($Value.StartsWith('"') -and $Value.EndsWith('"')) -or ($Value.StartsWith("'") -and $Value.EndsWith("'"))) {
                return $Value.Substring(1, $Value.Length - 2)
            } else {
                return $Value
            }
        }
    }

    return $null
}
