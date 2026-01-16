function Install-Unchecky {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory)]$Silent
    )

    Write-LogInfo 'Starting Unchecky installation...'

    Set-Variable -Option Constant IsConnected ([Boolean](Test-NetworkConnection))
    if (-not $IsConnected) {
        return
    }

    try {
        if ($Execute) {
            Set-Variable -Option Constant RegistryKey ([String]'HKCU:\Software\Unchecky')
            New-RegistryKeyIfMissing $RegistryKey
            Set-ItemProperty -Path $RegistryKey -Name 'HideTrayIcon' -Value 1
        }

        if ($Execute -and $Silent) {
            Set-Variable -Option Constant Params ([String]'-install -no_desktop_icon')
        }
    } catch [Exception] {
        Write-LogWarning 'Failed to configure Unchecky parameters'
    }

    Start-DownloadUnzipAndRun '{URL_UNCHECKY}' -Execute:$Execute -Params $Params -Silent:$Silent
}
