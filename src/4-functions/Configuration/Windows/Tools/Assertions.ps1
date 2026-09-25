function Test-WindowsDebloatIsRunning {
    # The script's path stays in the command line of the process it runs in, whether this app or the
    # project's own launcher started it
    return Find-RunningScript 'Win11Debloat.ps1'
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
