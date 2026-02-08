function Assert-WindowsDebloatIsRunning {
    return Find-RunningScript 'debloat.raphi.re'
}


function Assert-WinUtilIsRunning {
    return Find-RunningScript 'christitus.com'
}


function Assert-OOShutUp10IsRunning {
    return Find-RunningProcesses 'OOSU10'
}


function Assert-SdiIsRunning {
    return Find-RunningProcesses @('SDI64-drv', 'SDI-drv')
}


function Assert-OfficeInstallerRunning {
    return Find-RunningProcesses @('Office Installer.exe', 'Office Installer x86.exe')
}


function Assert-DownloadingWindowsUpdates {
    return Get-BitsTransfer -AllUsers | Where-Object JobState -EQ 'Transferring'
}


function Assert-InstallingWindowsUpdates {
    return Find-RunningProcesses @('TiWorker', 'TrustedInstaller')
}
