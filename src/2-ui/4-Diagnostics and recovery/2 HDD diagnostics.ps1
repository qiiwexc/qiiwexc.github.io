New-GroupBox 'HDD diagnostics'


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun '{URL_VICTORIA}' -Execute:$CHECKBOX_StartVictoria.Checked }
New-Button 'Victoria' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Checked
