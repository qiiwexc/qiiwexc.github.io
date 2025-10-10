function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $NINITE_CHECKBOXES.Where({ $_.Checked })
}


function Get-NiniteInstaller {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$OpenInBrowser,
        [Switch][Parameter(Position = 1)]$Execute
    )

    [String[]]$AppIds = @()

    foreach ($Checkbox in $NINITE_CHECKBOXES) {
        if ($Checkbox.Checked) {
            $AppIds += $Checkbox.Name
        }
    }

    Set-Variable -Option Constant Query ($AppIds -join '-')

    if ($OpenInBrowser) {
        Open-InBrowser "{URL_NINITE}/?select=$Query"
    } else {
        [String[]]$AppNames = @()

        foreach ($Checkbox in $NINITE_CHECKBOXES) {
            if ($Checkbox.Checked) {
                $AppNames += $Checkbox.Text
            }
        }

        Set-Variable -Option Constant FileName "Ninite $($AppNames -Join ' ') Installer.exe"
        Set-Variable -Option Constant DownloadUrl "{URL_NINITE}/$Query/ninite.exe"

        Start-DownloadUnzipAndRun $DownloadUrl $FileName -Execute:$Execute
    }
}
