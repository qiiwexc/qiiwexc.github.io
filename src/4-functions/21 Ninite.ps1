Set-Variable -Option Constant NiniteCheckboxes @(
    $CHECKBOX_Ninite_7zip,
    $CHECKBOX_Ninite_VLC,
    $CHECKBOX_Ninite_TeamViewer,
    $CHECKBOX_Ninite_Chrome,
    $CHECKBOX_Ninite_qBittorrent,
    $CHECKBOX_Ninite_Malwarebytes
)


function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $NiniteCheckboxes.Where({ $_.Checked })
}


function Get-NiniteInstaller {
    param(
        [Boolean][Parameter(Position = 0, Mandatory = $True)]$OpenInBrowser,
        [Boolean][Parameter(Position = 1)]$Execute
    )

    [String[]]$AppIds = @()

    foreach ($Checkbox in $NiniteCheckboxes) {
        if ($Checkbox.Checked) {
            $AppIds += $Checkbox.Name
        }
    }

    Set-Variable -Option Constant Query ($AppIds -join '-')

    if ($OpenInBrowser) {
        Open-InBrowser "{URL_NINITE}/?select=$Query"
    } else {
        [String[]]$AppNames = @()

        foreach ($Checkbox in $NiniteCheckboxes) {
            if ($Checkbox.Checked) {
                $AppNames += $Checkbox.Text
            }
        }

        Set-Variable -Option Constant FileName "Ninite $($AppNames -Join ' ') Installer.exe"
        Set-Variable -Option Constant DownloadUrl "{URL_NINITE}/$Query/ninite.exe"

        Start-DownloadUnzipAndRun -Execute:$Execute $DownloadUrl $FileName
    }
}
