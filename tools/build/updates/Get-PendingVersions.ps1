function Get-PendingVersions {
    param(
        [Parameter(Position = 0, Mandatory)][AllowEmptyCollection()][Collections.Specialized.OrderedDictionary]$State,
        [Parameter(Position = 1, Mandatory)][ValidateNotNullOrEmpty()][String]$Name,
        [Parameter(Position = 2, Mandatory)][ValidateNotNullOrEmpty()][String]$Version
    )

    if (-not $State.Contains($Name)) {
        return
    }

    [PSObject]$Entry = $State[$Name]
    [String[]]$Versions = @($Entry.candidates | ForEach-Object { $_.version })
    [Int]$Index = [Array]::LastIndexOf($Versions, $Version)

    # A version that is neither a candidate nor the one the candidates were recorded against is not what the
    # state describes: the dependency was changed by hand since
    if ($Index -lt 0 -and $Version -ne $Entry.base) {
        return
    }

    # Newest first, like the rest of the pull request description
    [PSObject[]]$Pending = @($Entry.candidates | Select-Object -Skip ($Index + 1) | ForEach-Object {
            [PSCustomObject]@{ Version = $_.version; EligibleOn = Get-QuarantineEnd $_.firstSeen }
        })
    [Array]::Reverse($Pending)

    return $Pending
}
