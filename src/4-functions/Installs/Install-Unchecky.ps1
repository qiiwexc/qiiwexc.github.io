function Install-Unchecky {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory)]$Silent
    )

    Write-LogInfo 'Starting Unchecky installation...'

    if ($Execute) {
        try {
            Set-Variable -Option Constant RegistryKey ([String]'HKCU:\Software\Unchecky')

            if (-not (Test-Path $RegistryKey)) {
                Write-LogDebug "Creating registry key '$RegistryKey'"
                New-Item $RegistryKey -ErrorAction Stop
            }

            Set-ItemProperty -Path $RegistryKey -Name 'HideTrayIcon' -Value 1 -ErrorAction Stop
        } catch {
            Write-LogWarning "Failed to configure Unchecky parameters: $_"
        }

        if ($Silent) {
            Set-Variable -Option Constant Params ([String]'-install -no_desktop_icon')
        }
    }

    Start-DownloadUnzipAndRun '{URL_UNCHECKY}' -Execute:$Execute -Params $Params -Silent:$Silent
}
