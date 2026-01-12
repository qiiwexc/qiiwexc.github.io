function Install-Unchecky {
    param(
        [Switch][Parameter(Position = 0, Mandatory)]$Execute,
        [Switch][Parameter(Position = 1, Mandatory)]$Silent
    )

    if ($Execute) {
        Set-Variable -Option Constant RegistryKey ([String]'HKCU:\Software\Unchecky')
        New-RegistryKeyIfMissing $RegistryKey
        Set-ItemProperty -Path $RegistryKey -Name 'HideTrayIcon' -Value 1
    }

    if ($Execute -and $Silent) {
        Set-Variable -Option Constant Params ([String]'-install -no_desktop_icon')
    }

    Start-DownloadUnzipAndRun '{URL_UNCHECKY}' -Execute:$Execute -Params $Params -Silent:$Silent
}
