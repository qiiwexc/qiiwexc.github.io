function Merge-JsonObject {
    param(
        [Parameter(Position = 0, Mandatory)][AllowNull()]$Source,
        [Parameter(Position = 1, Mandatory)][AllowNull()]$Extend
    )

    if ($Source -is [PSCustomObject] -and $Extend -is [PSCustomObject]) {
        $Merged = [Ordered]@{}

        foreach ($Property in $Source.PSObject.Properties) {
            $ExtendProp = $Extend.PSObject.Properties[$Property.Name]
            if (-not $ExtendProp -or $Null -eq $ExtendProp.Value) {
                $Merged[$Property.Name] = $Property.Value
            } else {
                $Merged[$Property.Name] = Merge-JsonObject $Property.Value $ExtendProp.Value
            }
        }

        foreach ($Property in $Extend.PSObject.Properties) {
            $SourceProp = $Source.PSObject.Properties[$Property.Name]
            if (-not $SourceProp -or $Null -eq $SourceProp.Value) {
                $Merged[$Property.Name] = $Property.Value
            }
        }

        return $Merged
    } elseif ($Extend -is [Collections.IList]) {
        # An array replaces the one it extends rather than being merged with it item by item: the items at the same
        # position of two lists are rarely the same thing, such as two different settings in a list of recorded
        # choices. The comma keeps an array of one or of none from being unrolled into a single value or nothing
        return , $Extend
    } else {
        return $Extend
    }
}
