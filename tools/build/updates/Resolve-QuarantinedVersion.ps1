function Resolve-QuarantinedVersion {
    param(
        [Parameter(Position = 0, Mandatory)][AllowEmptyCollection()][Collections.Specialized.OrderedDictionary]$State,
        [Parameter(Position = 1, Mandatory)][ValidateNotNullOrEmpty()][String]$Name,
        [Parameter(Position = 2, Mandatory)][ValidateNotNullOrEmpty()][String]$PreviousVersion,
        [Parameter(Position = 3, Mandatory)][ValidateNotNullOrEmpty()][String]$LatestVersion,
        [Parameter(Position = 4, Mandatory)][DateTime]$Now
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    if (-not $State.Contains($Name)) {
        $State[$Name] = [PSCustomObject]@{ base = $PreviousVersion; candidates = [Collections.Generic.List[PSObject]]::new() }
    }

    [PSObject]$Entry = $State[$Name]
    # The same list the state holds, even where the entry held an array, so the changes below stay in it
    [Collections.Generic.List[PSObject]]$Candidates = $Entry.candidates
    $Entry.candidates = $Candidates

    # The recorded version moved to a candidate when an update was merged, which leaves only the newer ones
    # waiting. A version that is neither a candidate nor the one they were recorded against was set by hand,
    # and nothing says how the candidates compare to it, so they start over: that only ever makes a wait longer
    [Int]$MergedIndex = @($Candidates | ForEach-Object { $_.version }).IndexOf($PreviousVersion)
    if ($MergedIndex -ge 0) {
        $Candidates.RemoveRange(0, $MergedIndex + 1)
        $Entry.base = $PreviousVersion
    } elseif ($Entry.base -ne $PreviousVersion) {
        $Candidates.Clear()
        $Entry.base = $PreviousVersion
    }

    # The check found nothing newer, or could not tell: the candidates stay, but none is applied on its word
    if ($LatestVersion -eq $PreviousVersion) {
        return $PreviousVersion
    }

    # A latest version seen before means the ones recorded after it were withdrawn
    [Int]$LatestIndex = @($Candidates | ForEach-Object { $_.version }).IndexOf($LatestVersion)
    if ($LatestIndex -ge 0) {
        $Candidates.RemoveRange($LatestIndex + 1, $Candidates.Count - $LatestIndex - 1)
    } else {
        $Candidates.Add([PSCustomObject]@{ version = $LatestVersion; firstSeen = $Now })
    }

    # The candidates are in the order they were first seen, so the last one out of quarantine is the newest
    [String]$TargetVersion = $PreviousVersion
    foreach ($Candidate in $Candidates) {
        [DateTime]$QuarantineEnd = Get-QuarantineEnd $Candidate.firstSeen
        if ($QuarantineEnd -le $Now) {
            $TargetVersion = $Candidate.version
        } else {
            Write-LogInfo "Version $($Candidate.version) is in quarantine until $($QuarantineEnd.ToString('yyyy-MM-dd HH:mm', [Globalization.CultureInfo]::InvariantCulture)) UTC" $LogIndentLevel
        }
    }

    return $TargetVersion
}
