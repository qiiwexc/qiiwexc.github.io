function Read-GitHubToken {
    param(
        [Parameter(Position = 0, Mandatory)][String]$EnvPath
    )

    Write-LogInfo 'Reading GitHub token'

    if ($env:GITHUB_TOKEN) {
        return $env:GITHUB_TOKEN
    }

    Set-Variable -Option Constant ResolvedPath ([String](Resolve-Path $EnvPath -ErrorAction SilentlyContinue))
    Set-Variable -Option Constant GitRoot ([String](Resolve-Path (git rev-parse --show-toplevel 2>$Null) -ErrorAction SilentlyContinue))

    if ($ResolvedPath -and $GitRoot -and -not $ResolvedPath.StartsWith($GitRoot)) {
        Write-LogWarning "Environment file path '$EnvPath' is outside the repository root"
        return
    }

    if (-not (Test-Path $EnvPath)) {
        Write-LogWarning "Environment file not found at path: $EnvPath"
        return
    }

    Set-Variable -Option Constant EnvContent ([String[]](Read-TextFile -AsList $EnvPath))
    Set-Variable -Option Constant Lines ([String[]]($EnvContent | ForEach-Object { $_.Trim() }))

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

    return
}
