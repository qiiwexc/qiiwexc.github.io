function Test-WindowsDebloatIsRunning {
    return Find-RunningScript 'debloat.raphi.re'
}


function Test-OOShutUp10IsRunning {
    return Find-RunningProcesses 'OOSU10'
}


function Test-SdiIsRunning {
    return Find-RunningProcesses @('SDI64-drv', 'SDI-drv')
}


function Test-DownloadingWindowsUpdates {
    return Get-BitsTransfer -AllUsers | Where-Object JobState -EQ 'Transferring'
}


function Test-InstallingWindowsUpdates {
    return Find-RunningProcesses @('TiWorker', 'TrustedInstaller')
}
