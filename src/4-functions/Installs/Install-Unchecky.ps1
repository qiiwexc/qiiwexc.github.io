function Install-Unchecky {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory = $True)]$Silent
    )

    Set-Variable -Option Constant Registry_Key 'HKCU:\Software\Unchecky'
    New-RegistryKeyIfMissing $Registry_Key

    Set-ItemProperty -Path $Registry_Key -Name 'HideTrayIcon' -Value 1

    Set-Variable -Option Constant Params $(if ($Silent) { '-install -no_desktop_icon' })
    Start-DownloadUnzipAndRun '{URL_UNCHECKY}' -Execute $Execute -Params $Params -Silent $Silent
}
