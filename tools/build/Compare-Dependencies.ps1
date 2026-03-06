function Compare-Dependencies {
    param(
        [Parameter(Position = 0, Mandatory)][Dependency[]]$OldDependencies,
        [Parameter(Position = 1, Mandatory)][Dependency[]]$NewDependencies,
        [Parameter(Position = 2, Mandatory)][PSCustomObject]$UrlsTemplate
    )

    [String[]]$UpdatedNames = @()
    [String[]]$UpdateDetails = @()
    [Bool]$HasUrlChange = $False

    foreach ($NewDep in $NewDependencies) {
        $OldDep = $OldDependencies | Where-Object { $_.name -eq $NewDep.name } | Select-Object -First 1

        if (-not $OldDep -or $OldDep.version -eq $NewDep.version) {
            continue
        }

        $UpdatedNames += $NewDep.name
        $UpdateDetails += "$($NewDep.name): $($OldDep.version) -> $($NewDep.version)"

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
    }
}
