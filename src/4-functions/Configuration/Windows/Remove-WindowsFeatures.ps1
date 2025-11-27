function Remove-WindowsFeatures {
    Set-Variable -Option Constant LogIndentLevel 1

    New-Activity 'Removing miscellaneous Windows features...'

    if ($PS_VERSION -ge 5) {
        try {
            Write-ActivityProgress -PercentComplete 5 -Task 'Collecting capabilities to remove...'
            Set-Variable -Option Constant InstalledCapabilities ([Object](Get-WindowsCapability -Online | Where-Object { $_.State -eq 'Installed' }))
            Set-Variable -Option Constant CapabilitiesToRemove ([Object]($InstalledCapabilities | Where-Object { $_.Name.Split('~')[0] -in $CONFIG_CAPABILITIES_TO_REMOVE }))
            Set-Variable -Option Constant CapabilityCount ([Int]($CapabilitiesToRemove.Count))
            Out-Success $LogIndentLevel
        } catch [Exception] {
            Write-LogException $_ 'Failed to collect capabilities to remove' $LogIndentLevel
        }
    }

    try {
        Write-ActivityProgress -PercentComplete 10 -Task 'Collecting features to remove...'
        Set-Variable -Option Constant InstalledFeatures ([Object](Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }))
        Set-Variable -Option Constant FeaturesToRemove ([Object]($InstalledFeatures | Where-Object { $_.FeatureName -in $CONFIG_FEATURES_TO_REMOVE }))
        Set-Variable -Option Constant FeatureCount ([Int]($FeaturesToRemove.Count))
        Out-Success $LogIndentLevel
    } catch [Exception] {
        Write-LogException $_ 'Failed to collect features to remove' $LogIndentLevel
    }

    if ($CapabilityCount) {
        Set-Variable -Option Constant CapabilityStep ([Math]::Floor(50 / $CapabilityCount))

        [Int]$Iteration = 1
        foreach ($Capability in $CapabilitiesToRemove) {
            [String]$Name = $Capability.Name
            try {
                [Int]$Percentage = 15 + $Iteration * $CapabilityStep
                Write-ActivityProgress -PercentComplete $Percentage -Task "Removing '$Name'..."
                $Iteration++
                Remove-WindowsCapability -Online -Name "$Name"
                Out-Success $LogIndentLevel
            } catch [Exception] {
                Write-LogException $_ "Failed to remove '$Name'" $LogIndentLevel
            }
        }
    }

    if ($FeatureCount) {
        Set-Variable -Option Constant FeatureStep ([Math]::Floor(20 / $FeatureCount))

        [Int]$Iteration = 1
        foreach ($Feature in $FeaturesToRemove) {
            [String]$Name = $Feature.FeatureName
            try {
                [Int]$Percentage = 70 + $Iteration * $FeatureStep
                Write-ActivityProgress -PercentComplete $Percentage -Task "Removing '$Name'..."
                $Iteration++
                Disable-WindowsOptionalFeature -Online -Remove -NoRestart -FeatureName "$Name"
                Out-Success $LogIndentLevel
            } catch [Exception] {
                Write-LogException $_ "Failed to remove '$Name'" $LogIndentLevel
            }
        }
    }

    if (Test-Path 'mstsc.exe') {
        Write-ActivityProgress -PercentComplete 90 -Task "Removing 'mstsc'..."
        Start-Process 'mstsc' '/uninstall'
        Out-Success $LogIndentLevel
    }

    Write-ActivityCompleted
}
