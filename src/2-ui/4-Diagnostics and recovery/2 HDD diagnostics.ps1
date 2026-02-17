New-Card 'HDD diagnostics'


[ScriptBlock]$BUTTON_FUNCTION = { Start-ChkDsk }
New-Button 'Check Disk' $BUTTON_FUNCTION


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartVictoria.IsChecked
    Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_VICTORIA}' -Execute:$Execute } -Variables @{
        Execute = $Execute
    }
}
New-Button 'Victoria' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Checked
