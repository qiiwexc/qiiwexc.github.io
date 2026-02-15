function Compare-Dependencies {
    param(
        [Dependency[]][Parameter(Position = 0, Mandatory)]$OldDependencies,
        [Dependency[]][Parameter(Position = 1, Mandatory)]$NewDependencies,
        [PSCustomObject][Parameter(Position = 2, Mandatory)]$UrlsTemplate
    )

    [String[]]$UpdatedNames = @()
    [String[]]$UpdateDetails = @()
    [Bool]$HasReleaseUpdate = $False

    foreach ($NewDep in $NewDependencies) {
        $OldDep = $OldDependencies | Where-Object { $_.name -eq $NewDep.name } | Select-Object -First 1

        if (-not $OldDep -or $OldDep.version -eq $NewDep.version) {
            continue
        }

        $UpdatedNames += $NewDep.name
        $UpdateDetails += "$($NewDep.name): $($OldDep.version) -> $($NewDep.version)"

        [String]$UrlKey = "URL_$($NewDep.name.ToUpper().Replace(' ', '_').Replace('-', '_'))"
        if ($null -ne $UrlsTemplate.$UrlKey) {
            $HasReleaseUpdate = $True
        }
    }

    return [PSCustomObject]@{
        UpdatedNames     = $UpdatedNames
        UpdateDetails    = $UpdateDetails
        HasReleaseUpdate = $HasReleaseUpdate
    }
}
