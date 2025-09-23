New-GroupBox 'Bootable USB tools'


[ScriptBlock]$BUTTON_FUNCTION = {
    Set-Variable -Option Constant FileName $((Split-Path -Leaf '{URL_VENTOY}') -Replace '-windows', '')
    Start-DownloadExtractExecute -Execute:$CHECKBOX_StartVentoy.Checked '{URL_VENTOY}' -FileName:$FileName
}
New-Button 'Windows Ventoy' $BUTTON_FUNCTION

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[Boolean]$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
[System.Windows.Forms.CheckBox]$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadExtractExecute -Execute:$CHECKBOX_StartRufus.Checked '{URL_RUFUS}' -Params:'-g' }
New-Button 'Rufus' $BUTTON_FUNCTION

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[Boolean]$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
[System.Windows.Forms.CheckBox]$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
