# Fails by throwing, so that Set-WindowsConfiguration changes nothing without the restore point it was asked for
function New-RestorePoint {
    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    # Off on many Windows 11 installs: turned on for the system drive, which reserves a few percent of it
    Set-Variable -Option Constant Settings ([PSObject](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore' -ErrorAction Stop))
    if (-not ($Settings.PSObject.Properties['RPSessionInterval'] -and $Settings.RPSessionInterval -ne 0)) {
        Write-LogInfo "System Restore is off, turning it on for drive $env:SystemDrive..." $LogIndentLevel
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop
    }

    Set-Variable -Option Constant Latest ([PSObject](Get-ComputerRestorePoint -ErrorAction Stop | Sort-Object SequenceNumber | Select-Object -Last 1))

    if ($Latest) {
        Set-Variable -Option Constant LatestSequenceNumber ([UInt32]$Latest.SequenceNumber)
        Set-Variable -Option Constant LatestCreated ([DateTime][Management.ManagementDateTimeConverter]::ToDateTime($Latest.CreationTime))
    } else {
        Set-Variable -Option Constant LatestSequenceNumber ([UInt32]0)
        Set-Variable -Option Constant LatestCreated ([DateTime]::MinValue)
    }

    # Windows creates at most one a day for an app, and skips the rest with only a warning: the latest one is as good
    if ($LatestCreated -gt (Get-Date).AddHours(-24)) {
        Write-LogInfo "Using restore point '$($Latest.Description)' from $($LatestCreated.ToString('g')), as Windows creates at most one a day" $LogIndentLevel
        Out-Success
        return
    }

    Checkpoint-Computer -Description 'Before qiiwexc Windows configuration' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop

    if (-not (Get-ComputerRestorePoint -ErrorAction Stop | Where-Object { $_.SequenceNumber -gt $LatestSequenceNumber })) {
        throw 'Windows did not create one'
    }

    Out-Success
}
