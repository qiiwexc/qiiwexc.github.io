function Write-QuarantineState {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path,
        [Parameter(Position = 1, Mandatory)][AllowEmptyCollection()][Collections.Specialized.OrderedDictionary]$State
    )

    [Collections.Specialized.OrderedDictionary]$Content = [Ordered]@{}

    foreach ($Name in $State.Keys) {
        [PSObject]$Entry = $State[$Name]

        # Only candidates are worth keeping: a dependency without any starts over from its current version
        if ($Entry.candidates.Count -eq 0) {
            continue
        }

        $Content[$Name] = [Ordered]@{
            base       = $Entry.base
            candidates = @($Entry.candidates | ForEach-Object {
                    # A string, as Windows PowerShell 5.1 would write a date as '\/Date(...)\/'
                    [Ordered]@{
                        version   = $_.version
                        firstSeen = "$($_.firstSeen.ToUniversalTime().ToString('s', [Globalization.CultureInfo]::InvariantCulture))Z"
                    }
                })
        }
    }

    Write-JsonFile $Path ([PSCustomObject]$Content)
}
