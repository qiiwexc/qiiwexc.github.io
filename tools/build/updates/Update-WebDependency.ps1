function Update-WebDependency {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Set-Variable -Option Constant Uri ([String]$Dependency.url)

    Write-LogInfo "Fetching URL: $Uri" $LogIndentLevel

    try {
        Set-Variable -Option Constant Response ([PSObject](Invoke-WebRequest $Uri -UseBasicParsing))
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

    Set-Variable -Option Constant Matches ([regex]::Matches($ResponseContent, $Dependency.regex, @('IgnoreCase', 'Multiline')))

    if ($Matches.Count -eq 0) {
        Out-Failure "Failed to find version number from URL '$Uri'" $LogIndentLevel
        return
    }

    Set-Variable -Option Constant LatestVersion ([String]($Matches[0].Groups[1].Value))

    if ($LatestVersion -ne '' -and $LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return @($Uri)
    }
}
