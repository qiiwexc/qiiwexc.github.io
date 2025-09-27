New-GroupBox 'Bootable USB tools'


[ScriptBlock]$BUTTON_FUNCTION = {
    Set-Variable -Option Constant FileName $((Split-Path -Leaf '{URL_VENTOY}') -replace '-windows', '')
    Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartVentoy.Checked '{URL_VENTOY}' -FileName:$FileName
}
New-Button 'Windows Ventoy' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartRufus.Checked '{URL_RUFUS}' -Params:'-g' }
New-Button 'Rufus' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Checked
