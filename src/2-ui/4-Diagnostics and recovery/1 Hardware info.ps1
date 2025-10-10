New-GroupBox 'Hardware info'


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun '{URL_CPU_Z}' -Execute $CHECKBOX_StartCpuZ.Checked }
New-Button 'CPU-Z' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartCpuZ = New-CheckBoxRunAfterDownload -Checked
