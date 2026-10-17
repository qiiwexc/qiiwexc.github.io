function Update-WebDependency {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Set-Variable -Option Constant Uri ([String]$Dependency.url)

    # Each failure throws rather than leaving the version as it is, which would read as "nothing newer"
    # and drop the versions waiting out their quarantine as withdrawn
    if (-not $Uri.StartsWith('https://')) {
        throw "Refusing to fetch version over insecure URL '$Uri': only HTTPS is allowed"
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
        throw "Failed to fetch URL '$Uri': $Message"
    }

    $ResponseContent = try { $Response.Content } catch { $null }
    if (-not $ResponseContent) {
        throw "No data fetched from URL '$Uri'"
    }

    # Named 'VersionMatches' to avoid colliding with the automatic $Matches variable,
    # which any earlier -match/-notmatch operation in this scope would have created
    Set-Variable -Option Constant VersionMatches ([regex]::Matches($ResponseContent, $Dependency.regex, @('IgnoreCase', 'Multiline')))

    if ($VersionMatches.Count -eq 0) {
        throw "Failed to find version number from URL '$Uri'"
    }

    Set-Variable -Option Constant LatestVersion ([String]($VersionMatches[0].Groups[1].Value))

    # Scraped version strings end up in dependencies.json and, for URL-mapped
    # dependencies, inside the built artifact — reject anything that could break
    # out of a string or markup context, and absurd lengths (scraping gone wrong)
    if ($LatestVersion.Length -gt 100 -or $LatestVersion -match '[''"`$<>{}]' -or $LatestVersion -match '\r|\n') {
        throw "Scraped version for '$($Dependency.name)' looks unsafe, ignoring it: $LatestVersion"
    }

    if ($LatestVersion -ne '' -and $LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return @($Uri)
    }
}
