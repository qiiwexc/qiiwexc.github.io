New-GroupBox 'HDD diagnostics'


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartVictoria.Checked '{URL_VICTORIA}' }
New-Button 'Victoria' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Checked
