New-GroupBox 'HDD diagnostics'


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartVictoria.Checked '{URL_VICTORIA}' }
New-Button 'Victoria' $BUTTON_FUNCTION

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[Boolean]$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
[System.Windows.Forms.CheckBox]$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
