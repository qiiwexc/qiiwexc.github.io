function Merge-JsonObject {
    param(
        [Parameter(Position = 0, Mandatory = $True)]$Source,
        [Parameter(Position = 1, Mandatory = $True)]$Extend
    )

    if ($Source -is [PSCustomObject] -and $Extend -is [PSCustomObject]) {
        [PSCustomObject]$Merged = [Ordered] @{}

        foreach ($Property in $Source.PSObject.Properties) {
            if ($Null -eq $Extend.$($Property.Name)) {
                $Merged[$Property.Name] = $Property.Value
            } else {
                $Merged[$Property.Name] = Merge-JsonObject $Property.Value $Extend.$($Property.Name)
            }
        }

        foreach ($Property in $Extend.PSObject.Properties) {
            if ($Null -eq $Source.$($Property.Name)) {
                $Merged[$Property.Name] = $Property.Value
            }
        }

        $Merged
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

        , $Merged
    } else {
        $Extend
    }
}
