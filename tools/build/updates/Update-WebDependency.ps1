function Update-WebDependency {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Set-Variable -Option Constant Uri ([String]$Dependency.url)

    if (-not $Uri.StartsWith('https://')) {
        Out-Failure "Refusing to fetch version over insecure URL '$Uri': only HTTPS is allowed" $LogIndentLevel
        return
    }

    Write-LogInfo "Fetching URL: $Uri" $LogIndentLevel

    try {
        Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest $Uri -UseBasicParsing -TimeoutSec 30))
    } catch {
        $ExceptionResponse = try { $_.Exception.Response } catch { $null }
        [String]$Message = if ($ExceptionResponse) {
            "HTTP $([Int]$ExceptionResponse.StatusCode) $($ExceptionResponse.StatusCode)"
        } else {
            $_.Exception.Message
        }
        Out-Failure "Failed to fetch URL '$Uri': $Message" $LogIndentLevel
        return
    }

    $ResponseContent = try { $Response.Content } catch { $null }
    if (-not $ResponseContent) {
        Out-Failure "No data fetched from URL '$Uri'" $LogIndentLevel
        return
    }

    # Named 'VersionMatches' to avoid colliding with the automatic $Matches variable,
    # which any earlier -match/-notmatch operation in this scope would have created
    Set-Variable -Option Constant VersionMatches ([regex]::Matches($ResponseContent, $Dependency.regex, @('IgnoreCase', 'Multiline')))

    if ($VersionMatches.Count -eq 0) {
        Out-Failure "Failed to find version number from URL '$Uri'" $LogIndentLevel
        return
    }

    Set-Variable -Option Constant LatestVersion ([String]($VersionMatches[0].Groups[1].Value))

    # Scraped version strings end up in dependencies.json and, for URL-mapped
    # dependencies, inside the built artifact — reject anything that could break
    # out of a string or markup context, and absurd lengths (scraping gone wrong)
    if ($LatestVersion.Length -gt 100 -or $LatestVersion -match '[''"`$<>{}]' -or $LatestVersion -match '\r|\n') {
        Out-Failure "Scraped version for '$($Dependency.name)' looks unsafe, ignoring it: $LatestVersion" $LogIndentLevel
        return
    }

    if ($LatestVersion -ne '' -and $LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return @($Uri)
    }
}
