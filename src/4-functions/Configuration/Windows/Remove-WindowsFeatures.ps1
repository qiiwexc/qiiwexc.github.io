function Remove-WindowsFeatures {
    New-Activity 'Removing miscellaneous Windows features...'

    Set-Variable -Option Constant FeaturesToRemove @('App.StepsRecorder',
        'App.Support.QuickAssist',
        'MathRecognizer',
        'Media.WindowsMediaPlayer',
        'Microsoft.Windows.WordPad',
        'OpenSSH.Client'
    )

    try {
        Write-ActivityProgress -PercentComplete 5 -Task 'Collecting the features to remove...'
        Set-Variable -Option Constant InstalledCapabilities (Get-WindowsCapability -Online | Where-Object { $_.State -eq 'Installed' })
        Set-Variable -Option Constant CapabilitiesToRemove ($InstalledCapabilities | Where-Object { $_.Name.Split('~')[0] -in $FeaturesToRemove })
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to collect the features to remove'
    }

    Set-Variable -Option Constant CapabilityCount ($CapabilitiesToRemove.Count)

    if ($CapabilityCount -eq 0) {
        Write-LogInfo 'Nothing to remove'
    } else {
        Set-Variable -Option Constant Step ([Math]::Floor(80 / $CapabilityCount))

        [Int]$Iteration = 1
        foreach ($Capability in $CapabilitiesToRemove) {
            [String]$Name = $Capability.Name
            try {
                [Int]$Percentage = 10 + $Iteration * $Step
                Write-ActivityProgress -PercentComplete $Percentage -Task "Removing '$Name'..."
                $Iteration++
                Remove-WindowsCapability -Online -Name "$Name"
                Out-Success
            } catch [Exception] {
                Write-ExceptionLog $_ "Failed to remove '$Name'"
            }
        }
    }

    if (Test-Path 'mstsc.exe') {
        Write-ActivityProgress -PercentComplete 90 -Task "Removing 'mstsc'..."
        Start-Process 'mstsc' '/uninstall'
        Out-Success
    }

    Write-ActivityCompleted
}
