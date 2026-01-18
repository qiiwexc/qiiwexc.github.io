New-GroupBox 'Ninite'

[Switch]$PAD_CHECKBOXES = $False


[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Chrome = New-CheckBox 'Google Chrome' -Name 'chrome' -Checked
$CHECKBOX_Ninite_Chrome.Add_CheckStateChanged( { Set-NiniteButtonState } )

[Windows.Forms.CheckBox]$CHECKBOX_Ninite_7zip = New-CheckBox '7-Zip' -Name '7zip' -Checked
$CHECKBOX_Ninite_7zip.Add_CheckStateChanged( { Set-NiniteButtonState } )

[Windows.Forms.CheckBox]$CHECKBOX_Ninite_VLC = New-CheckBox 'VLC' -Name 'vlc' -Checked
$CHECKBOX_Ninite_VLC.Add_CheckStateChanged( { Set-NiniteButtonState } )

[Windows.Forms.CheckBox]$CHECKBOX_Ninite_AnyDesk = New-CheckBox 'AnyDesk' -Name 'anydesk' -Checked
$CHECKBOX_Ninite_AnyDesk.Add_CheckStateChanged( { Set-NiniteButtonState } )

[Windows.Forms.CheckBox]$CHECKBOX_Ninite_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qbittorrent'
$CHECKBOX_Ninite_qBittorrent.Add_CheckStateChanged( { Set-NiniteButtonState } )

[Windows.Forms.CheckBox]$CHECKBOX_Ninite_Malwarebytes = New-CheckBox 'Malwarebytes' -Name 'malwarebytes'
$CHECKBOX_Ninite_Malwarebytes.Add_CheckStateChanged( { Set-NiniteButtonState } )


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
        $CHECKBOX_Ninite_qBittorrent,
        $CHECKBOX_Ninite_Malwarebytes
    )
)
