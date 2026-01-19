function Remove-WindowsFeatures {
    Set-Variable -Option Constant LogIndentLevel 1

    New-Activity 'Removing miscellaneous Windows features'

    try {
        Write-ActivityProgress 5 'Collecting capabilities to remove...'
        Set-Variable -Option Constant InstalledCapabilities ([PSCustomObject](Get-WindowsCapability -Online | Where-Object { $_.State -eq 'Installed' }))
        Set-Variable -Option Constant CapabilitiesToRemove ([PSCustomObject]($InstalledCapabilities | Where-Object { $_.Name.Split('~')[0] -in $CONFIG_CAPABILITIES_TO_REMOVE }))
        Set-Variable -Option Constant CapabilityCount ([Int]($CapabilitiesToRemove.Count))
        Out-Success $LogIndentLevel
    } catch {
        Write-LogError "Failed to collect capabilities to remove: $_" $LogIndentLevel
    }

    try {
        Write-ActivityProgress 10 'Collecting features to remove...'
        Set-Variable -Option Constant InstalledFeatures ([PSCustomObject](Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }))
        Set-Variable -Option Constant FeaturesToRemove ([PSCustomObject]($InstalledFeatures | Where-Object { $_.FeatureName -in $CONFIG_FEATURES_TO_REMOVE }))
        Set-Variable -Option Constant FeatureCount ([Int]($FeaturesToRemove.Count))
        Out-Success $LogIndentLevel
    } catch {
        Write-LogError "Failed to collect features to remove: $_" $LogIndentLevel
    }

    if ($CapabilityCount) {
        Set-Variable -Option Constant CapabilityStep ([Math]::Floor(40 / $CapabilityCount))

        [Int]$Iteration = 1
        foreach ($Capability in $CapabilitiesToRemove) {
            [String]$Name = $Capability.Name
            try {
                [Int]$Percentage = 20 + $Iteration * $CapabilityStep
                Write-ActivityProgress $Percentage "Removing '$Name'..."
                $Iteration++
                Remove-WindowsCapability -Online -Name "$Name"
                Out-Success $LogIndentLevel
            } catch {
                Write-LogError "Failed to remove '$Name': $_" $LogIndentLevel
            }
        }
    }

    if ($FeatureCount) {
        Set-Variable -Option Constant FeatureStep ([Math]::Floor(40 / $FeatureCount))

        [Int]$Iteration = 1
        foreach ($Feature in $FeaturesToRemove) {
            [String]$Name = $Feature.FeatureName
            try {
                [Int]$Percentage = 60 + $Iteration * $FeatureStep
                Write-ActivityProgress $Percentage "Removing '$Name'..."
                $Iteration++
                Disable-WindowsOptionalFeature -Online -Remove -NoRestart -FeatureName "$Name"
                Out-Success $LogIndentLevel
            } catch {
                Write-LogError "Failed to remove '$Name': $_" $LogIndentLevel
            }
        }
    }

    Write-ActivityCompleted
}
