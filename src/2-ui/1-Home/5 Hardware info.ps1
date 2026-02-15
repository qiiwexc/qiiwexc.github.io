New-Card 'Hardware info'


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartCpuZ.IsChecked
    Start-AsyncOperation -Sender $this { Start-DownloadUnzipAndRun '{URL_CPU_Z}' -Execute:$Execute } -Variables @{
        Execute = $Execute
    }
}
New-Button 'CPU-Z' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartCpuZ = New-CheckBoxRunAfterDownload -Checked
