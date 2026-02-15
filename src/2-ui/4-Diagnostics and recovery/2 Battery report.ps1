New-Card 'Battery report'


[ScriptBlock]$BUTTON_FUNCTION = { Start-AsyncOperation -Sender $this { Get-BatteryReport } }
New-Button 'Get battery report' $BUTTON_FUNCTION -Disabled:(-not $IS_LAPTOP)
