function Remove-WindowsFeatures {
    New-Activity 'Removing miscellaneous Windows features'

    try {
        Write-ActivityProgress 10 'Collecting features to remove...'
        Set-Variable -Option Constant InstalledFeatures ([PSCustomObject](Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }))
        Set-Variable -Option Constant FeaturesToRemove ([PSCustomObject]($InstalledFeatures | Where-Object { $_.FeatureName -in $CONFIG_FEATURES_TO_REMOVE }))
        Set-Variable -Option Constant FeatureCount ([Int]($FeaturesToRemove.Count))
        Out-Success
    } catch {
        Out-Failure "Failed to collect features to remove: $_"
    }

    if ($FeatureCount) {
        Set-Variable -Option Constant FeatureStep ([Math]::Floor(80 / $FeatureCount))

        [Int]$Iteration = 1
        foreach ($Feature in $FeaturesToRemove) {
            [String]$Name = $Feature.FeatureName
            try {
                [Int]$Percentage = 20 + $Iteration * $FeatureStep
                Write-ActivityProgress $Percentage "Removing '$Name'..."
                $Iteration++
                Disable-WindowsOptionalFeature -Online -Remove -NoRestart -FeatureName "$Name"
                Out-Success
            } catch {
                Out-Failure "Failed to remove '$Name': $_"
            }
        }
    }

    Write-ActivityCompleted
}
