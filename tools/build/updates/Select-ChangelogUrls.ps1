function Select-ChangelogUrls {
    param(
        [Parameter(Position = 0, Mandatory)][AllowEmptyCollection()][String[]]$Urls,
        [Parameter(Position = 1, Mandatory)][ValidateNotNullOrEmpty()][String]$LatestVersion,
        [Parameter(Position = 2, Mandatory)][ValidateNotNullOrEmpty()][String]$TargetVersion
    )

    # The updaters link every version up to the latest; an update held back by the quarantine goes only as far
    # as the target, and the links past it would quote notes of versions this update does not bring
    [Collections.Generic.List[String]]$Selected = @()

    foreach ($Url in $Urls) {
        if ($Url -match '/releases/tag/(?<tag>[^/?#]+)$') {
            [String]$Tag = [Uri]::UnescapeDataString($Matches['tag'])
            [Bool]$IsCrossed = $Tag -eq $TargetVersion
            if (-not $IsCrossed) {
                # A tag that does not read as a version cannot be placed, so only the target's own is kept
                try {
                    $IsCrossed = [Version]($Tag -replace '^v' -replace '-.*$') -le [Version]($TargetVersion -replace '^v' -replace '-.*$')
                } catch {
                    $IsCrossed = $False
                }
            }

            if ($IsCrossed) {
                $Selected.Add($Url)
            }
        } elseif ($Url.EndsWith("...$LatestVersion")) {
            # A comparison with the latest version, from commits, tags or GitLab
            $Selected.Add($Url.Substring(0, $Url.Length - $LatestVersion.Length) + $TargetVersion)
        } else {
            $Selected.Add($Url)
        }
    }

    return $Selected.ToArray()
}
