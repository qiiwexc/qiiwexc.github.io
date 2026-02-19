New-Card 'HDD diagnostics'


[ScriptBlock]$BUTTON_FUNCTION = {
    $ScheduleFullScan = $CHECKBOX_ChkDskScheduleFullScan.IsChecked
    Start-AsyncOperation -Button $this { Start-ChkDsk -ScheduleFullScan:$ScheduleFullScan } -Variables @{
        ScheduleFullScan = $ScheduleFullScan
    }
}
New-Button 'Check Disk' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_ChkDskScheduleFullScan = New-CheckBox 'Run full scan after restart'


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartVictoria.IsChecked
    Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_VICTORIA}' -Execute:$Execute } -Variables @{
        Execute = $Execute
    }
}
New-Button 'Victoria' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartVictoria = New-CheckBoxRunAfterDownload -Checked
