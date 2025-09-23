Function Remove-WindowsFeatures {
    Write-Log $INF "Starting miscellaneous Windows features cleanup..."

    Set-Variable -Option Constant FeaturesToRemove @("App.StepsRecorder",
        "MathRecognizer",
        "Media.WindowsMediaPlayer",
        "Microsoft.Windows.PowerShell.ISE",
        "OpenSSH.Client",
        "VBSCRIPT"
    )

    try {
        Set-Variable -Option Constant InstalledCapabilities (Get-WindowsCapability -Online | Where-Object { $_.State -eq 'Installed' })
        Set-Variable -Option Constant CapabilitiesToRemove ($InstalledCapabilities | Where-Object { $_.Name.Split('~')[0] -in $FeaturesToRemove })
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to collect the features to remove'
    }

    ForEach ($Capability in $CapabilitiesToRemove) {
        [String]$Name = $Capability.Name
        try {
            Write-Log $INF "Removing '$Name'..."
            Remove-WindowsCapability -Online -Name "$Name"
            Out-Success
        } catch [Exception] {
            Write-ExceptionLog $_ "Failed to remove '$Name'"
        }
    }

    if ($CapabilitiesToRemove.Count -eq 0) {
        Out-Success
    }

    if (Test-Path 'mstsc.exe') {
        Write-Log $INF "Removing 'mstsc'..."
        Start-Process 'mstsc' '/uninstall'
        Out-Success
    }
}
