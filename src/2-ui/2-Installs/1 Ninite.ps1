New-GroupBox 'Ninite'

[Switch]$PAD_CHECKBOXES = $False


[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Firefox = New-CheckBox 'Mozilla Firefox' -Name 'firefox' -Checked
[Windows.Forms.CheckBox]$CHECKBOX_Ninite_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
[Windows.Forms.CheckBox]$CHECKBOX_Ninite_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
[Windows.Forms.CheckBox]$CHECKBOX_Ninite_AnyDesk = New-CheckBox 'AnyDesk' -Name 'anydesk' -Checked
[Windows.Forms.CheckBox]$CHECKBOX_Ninite_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'


[ScriptBlock]$BUTTON_FUNCTION = { Get-NiniteInstaller -OpenInBrowser:(-not $CHECKBOX_StartNinite.Enabled) -Execute:$CHECKBOX_StartNinite.Checked }
New-Button 'Download selected' $BUTTON_FUNCTION


[Windows.Forms.CheckBox]$CHECKBOX_StartNinite = New-CheckBoxRunAfterDownload -Checked

[ScriptBlock]$BUTTON_FUNCTION = { Get-NiniteInstaller -OpenInBrowser }
New-ButtonBrowser 'View other' $BUTTON_FUNCTION


Set-Variable -Option Constant NINITE_CHECKBOXES (
    [Windows.Forms.CheckBox[]]@(
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
    $Checkbox.Add_CheckStateChanged( { Set-NiniteButtonState } )
}
