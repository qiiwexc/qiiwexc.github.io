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
    } elseif ($Source -is [Collections.IList] -and $Extend -is [Collections.IList]) {
        Set-Variable -Option Constant MaxCount ([Math]::Max($Source.Count, $Extend.Count))

        [Collections.IList]$Merged = for ($i = 0; $i -lt $MaxCount; ++$i) {
            if ($i -ge $Source.Count) {
                $Extend[$i]
            } elseif ($i -ge $Extend.Count) {
                $Source[$i]
            } else {
                Merge-JsonObject $Source[$i] $Extend[$i]
            }
        }

        return , $Merged
    } else {
        return $Extend
    }
}
