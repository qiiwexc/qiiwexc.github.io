function Set-NiniteButtonState {
    $CHECKBOX_StartNinite.IsEnabled = $NINITE_CHECKBOXES.Where({ $_.IsChecked }, 'First', 1)
}


function Get-NiniteInstaller {
    param(
        [Object[]][Parameter(Position = 0, Mandatory)]$Checkboxes,
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

        Start-DownloadUnzipAndRun $DownloadUrl $FileName -Execute:$Execute
    }
}
