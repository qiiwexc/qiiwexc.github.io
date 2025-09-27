New-GroupBox 'Hardware info'


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartCpuZ.Checked '{URL_CPU_Z}' }
New-Button 'CPU-Z' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartCpuZ = New-CheckBoxRunAfterDownload -Checked
