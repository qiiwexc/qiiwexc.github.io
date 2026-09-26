function Set-NiniteButtonState {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Controls.CheckBox[]]$Checkboxes,
        [Parameter(Position = 1, Mandatory)][Windows.Controls.CheckBox]$StartCheckbox
    )

    # There is nothing to start without an app to install
    $StartCheckbox.IsEnabled = [Bool]$Checkboxes.Where({ $_.IsChecked }, 'First', 1).Count
}


function Get-NiniteInstaller {
    param(
        [Parameter(Position = 0, Mandatory)][Object[]]$Checkboxes,
        [Switch]$OpenInBrowser,
        [Switch]$Execute
    )

    [Collections.Generic.List[String]]$AppIds = @()

    foreach ($Checkbox in $Checkboxes) {
        if ($Checkbox.IsChecked) {
            $AppIds.Add($Checkbox.Tag)
        }
    }

    Set-Variable -Option Constant Query ([String]($AppIds -join '-'))

    if ($OpenInBrowser) {
        Open-InBrowser "{URL_NINITE}/?select=$Query"
    } else {
        [Collections.Generic.List[String]]$AppNames = @()

        foreach ($Checkbox in $Checkboxes) {
            if ($Checkbox.IsChecked) {
                $AppNames.Add([String]$Checkbox.Content)
            }
        }

        Set-Variable -Option Constant FileName ([String]"Ninite $($AppNames -Join ' ') Installer.exe")
        Set-Variable -Option Constant DownloadUrl ([String]"{URL_NINITE}/$Query/ninite.exe")

        Start-DownloadUnzipAndRun $DownloadUrl $FileName -Execute:$Execute -NoBits
    }
}
