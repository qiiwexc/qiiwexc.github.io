function Read-QuarantineState {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path,
        [Parameter(Position = 1, Mandatory)][DateTime]$Now
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    # By dependency name: the version the candidates were recorded against ('base'), and the versions seen
    # since, oldest first, each with the time the update check first saw it
    [Collections.Specialized.OrderedDictionary]$State = [Ordered]@{}

    if (-not (Test-Path $Path)) {
        Write-LogInfo "No quarantine state at '$Path', so every new version starts its wait now" $LogIndentLevel
        return $State
    }

    try {
        $Content = Read-JsonFile $Path
    } catch {
        Write-LogWarning "Unreadable quarantine state at '$Path', so every new version starts its wait now: $_" $LogIndentLevel
        return $State
    }

    if ($Content -isnot [Management.Automation.PSCustomObject]) {
        Write-LogWarning "Quarantine state at '$Path' is not an object, so every new version starts its wait now" $LogIndentLevel
        return $State
    }

    # The CI copy comes from a workflow artifact, and a version read here can end up in dependencies.json and
    # the built script, so the same limits apply as to a scraped one
    Set-Variable -Option Constant IsSafeVersion ([ScriptBlock]{
            param([Object]$Version)
            return $Version -is [String] -and $Version -and $Version.Length -le 100 -and $Version -notmatch '[''"`$<>{}\r\n]'
        })

    [Int]$DroppedCount = 0

    foreach ($Property in $Content.PSObject.Properties) {
        $Entry = $Property.Value

        if (-not ($Entry -is [Management.Automation.PSCustomObject] -and $Entry.PSObject.Properties['base'] -and $Entry.PSObject.Properties['candidates'] -and (& $IsSafeVersion $Entry.base))) {
            $DroppedCount++
            continue
        }

        [Collections.Generic.List[PSObject]]$Candidates = @()

        foreach ($Candidate in @($Entry.candidates)) {
            if (-not ($Candidate -is [Management.Automation.PSCustomObject] -and $Candidate.PSObject.Properties['version'] -and $Candidate.PSObject.Properties['firstSeen'] -and (& $IsSafeVersion $Candidate.version))) {
                $DroppedCount++
                continue
            }

            # Windows PowerShell 5.1 reads the time as the string it was written as, PowerShell 7 as a date
            [Object]$Seen = $Candidate.firstSeen
            [DateTime]$FirstSeen = [DateTime]::MinValue
            if ($Seen -is [DateTime]) {
                $FirstSeen = if ($Seen.Kind -eq [DateTimeKind]::Unspecified) { [DateTime]::SpecifyKind($Seen, [DateTimeKind]::Utc) } else { $Seen.ToUniversalTime() }
            } elseif (-not ($Seen -is [String] -and [DateTime]::TryParse($Seen, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]'AdjustToUniversal, AssumeUniversal', [Ref]$FirstSeen))) {
                $DroppedCount++
                continue
            }

            # A time in the future would let a version skip part of its wait
            if ($FirstSeen -gt $Now) {
                $FirstSeen = $Now
            }

            $Candidates.Add([PSCustomObject]@{ version = [String]$Candidate.version; firstSeen = $FirstSeen })
        }

        if ($Candidates.Count -gt 0) {
            $State[$Property.Name] = [PSCustomObject]@{ base = [String]$Entry.base; candidates = $Candidates }
        }
    }

    if ($DroppedCount -gt 0) {
        Write-LogWarning "Ignored $DroppedCount malformed entries in the quarantine state at '$Path'" $LogIndentLevel
    }

    return $State
}
