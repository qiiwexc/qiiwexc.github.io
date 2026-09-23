function Compare-Dependencies {
    param(
        [Parameter(Position = 0, Mandatory)][Dependency[]]$OldDependencies,
        [Parameter(Position = 1, Mandatory)][Dependency[]]$NewDependencies,
        [Parameter(Position = 2, Mandatory)][PSCustomObject]$UrlsTemplate
    )

    # Tools the CI itself runs — a new version changes what the tests and the linter check
    Set-Variable -Option Constant ToolNames ([String[]]@('Pester', 'PSScriptAnalyzer'))

    [String[]]$UpdatedNames = @()
    [String[]]$UpdateDetails = @()
    [Bool]$HasUrlChange = $False
    [Bool]$HasToolChange = $False

    foreach ($NewDep in $NewDependencies) {
        $OldDep = $OldDependencies | Where-Object { $_.name -eq $NewDep.name } | Select-Object -First 1

        if (-not $OldDep -or $OldDep.version -eq $NewDep.version) {
            continue
        }

        $UpdatedNames += $NewDep.name
        $UpdateDetails += "$($NewDep.name): $($OldDep.version) -> $($NewDep.version)"

        if ($NewDep.name -in $ToolNames) {
            $HasToolChange = $True
        }

        [String]$UrlKey = "URL_$($NewDep.name.ToUpper().Replace(' ', '_').Replace('-', '_'))"
        if ($UrlsTemplate.PSObject.Properties[$UrlKey]) {
            [String]$OldUrl = $UrlsTemplate.$UrlKey.Replace('{VERSION}', $OldDep.version.TrimStart('v'))
            [String]$NewUrl = $UrlsTemplate.$UrlKey.Replace('{VERSION}', $NewDep.version.TrimStart('v'))
            if ($OldUrl -ne $NewUrl) {
                $HasUrlChange = $True
            }
        }
    }

    return [PSCustomObject]@{
        UpdatedNames  = $UpdatedNames
        UpdateDetails = $UpdateDetails
        HasUrlChange  = $HasUrlChange
        HasToolChange = $HasToolChange
    }
}
