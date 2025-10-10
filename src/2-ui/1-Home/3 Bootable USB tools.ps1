New-GroupBox 'Bootable USB tools'


[ScriptBlock]$BUTTON_FUNCTION = {
    Set-Variable -Option Constant FileName $((Split-Path -Leaf '{URL_VENTOY}').Replace('-windows', ''))
    Start-DownloadUnzipAndRun '{URL_VENTOY}' $FileName -Execute:$CHECKBOX_StartVentoy.Checked
}
New-Button 'Windows Ventoy' $BUTTON_FUNCTION

[Windows.Forms.CheckBox]$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun '{URL_RUFUS}' -Execute:$CHECKBOX_StartRufus.Checked -Params '-g' }
New-Button 'Rufus' $BUTTON_FUNCTION

[Windows.Forms.CheckBox]$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Checked
