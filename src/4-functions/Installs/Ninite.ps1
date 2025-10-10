function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.Enabled = $NINITE_CHECKBOXES.Where({ $_.Checked })
}


function Get-NiniteInstaller {
    param(
        [Switch][Parameter(Position = 0, Mandatory = $True)]$OpenInBrowser,
        [Switch][Parameter(Position = 1)]$Execute
    )

    [Collections.Generic.List[String]]$AppIds = @()

    foreach ($Checkbox in $NINITE_CHECKBOXES) {
        if ($Checkbox.Checked) {
            $AppIds.Add($Checkbox.Name)
        }
    }

    Set-Variable -Option Constant Query ($AppIds -join '-')

    if ($OpenInBrowser) {
        Open-InBrowser "{URL_NINITE}/?select=$Query"
    } else {
        [Collections.Generic.List[String]]$AppNames = @()

        foreach ($Checkbox in $NINITE_CHECKBOXES) {
            if ($Checkbox.Checked) {
                $AppNames.Add($Checkbox.Text)
            }
        }

        Set-Variable -Option Constant FileName "Ninite $($AppNames -Join ' ') Installer.exe"
        Set-Variable -Option Constant DownloadUrl "{URL_NINITE}/$Query/ninite.exe"

        Start-DownloadUnzipAndRun $DownloadUrl $FileName -Execute:$Execute
    }
}
