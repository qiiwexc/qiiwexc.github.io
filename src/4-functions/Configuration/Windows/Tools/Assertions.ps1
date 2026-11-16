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


function Test-ActivatorIsRunning {
    # This app and the project's own launcher both run MAS as a copy named MAS_<GUID>.cmd in a temp folder
    return Find-RunningScript '\Temp\MAS_'
}


function Test-DownloadingWindowsUpdates {
    # Windows Update transfers as the system account, while a signed-in user's transfers, this app's own downloads
    # among them, are not updates. The account is named from its SID, as Windows translates the name
    Set-Variable -Option Constant SystemAccount ([String]([Security.Principal.SecurityIdentifier]'S-1-5-18').Translate([Security.Principal.NTAccount]).Value)

    return Get-BitsTransfer -AllUsers | Where-Object { $_.JobState -eq 'Transferring' -and $_.OwnerAccount -eq $SystemAccount }
}


function Test-InstallingWindowsUpdates {
    return Find-RunningProcesses @('TiWorker', 'TrustedInstaller')
}
