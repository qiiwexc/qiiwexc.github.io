New-Card 'Ninite'


[Windows.Controls.CheckBox]$CHECKBOX_Ninite_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Ninite_Firefox = New-CheckBox 'Mozilla Firefox' -Name 'firefox' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Ninite_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Ninite_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Ninite_AnyDesk = New-CheckBox 'AnyDesk' -Name 'anydesk' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Ninite_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
[Windows.Controls.CheckBox]$CHECKBOX_Ninite_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'


[ScriptBlock]$BUTTON_FUNCTION = {
    $CapturedCheckboxes = $NINITE_CHECKBOXES | ForEach-Object { [PSCustomObject]@{ IsChecked = $_.IsChecked; Tag = [String]$_.Tag; Content = [String]$_.Content } }
    $Execute = $CHECKBOX_StartNinite.IsChecked
    $OpenInBrowser = -not $CHECKBOX_StartNinite.IsEnabled
    Start-AsyncOperation -Button $this { Get-NiniteInstaller $CapturedCheckboxes -OpenInBrowser:$OpenInBrowser -Execute:$Execute } -Variables @{
        CapturedCheckboxes = $CapturedCheckboxes
        Execute            = $Execute
        OpenInBrowser      = $OpenInBrowser
    }
}
New-Button 'Install selected' $BUTTON_FUNCTION


[Windows.Controls.CheckBox]$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked

[ScriptBlock]$BUTTON_FUNCTION = { Get-NiniteInstaller $NINITE_CHECKBOXES -OpenInBrowser }
New-ButtonBrowser 'More' $BUTTON_FUNCTION


Set-Variable -Option Constant NINITE_CHECKBOXES (
    [Windows.Controls.CheckBox[]]@(
        $CHECKBOX_Ninite_7zip,
        $CHECKBOX_Ninite_VLC,
        $CHECKBOX_Ninite_AnyDesk,
        $CHECKBOX_Ninite_Chrome,
        $CHECKBOX_Ninite_Firefox,
        $CHECKBOX_Ninite_qBittorrent,
        $CHECKBOX_Ninite_Malwarebytes
    )
)

foreach ($Checkbox in $NINITE_CHECKBOXES) {
    $Checkbox.Add_Checked( { Set-NiniteButtonState } )
    $Checkbox.Add_Unchecked( { Set-NiniteButtonState } )
}
