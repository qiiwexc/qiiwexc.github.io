New-GroupBox 'Battery report'


[ScriptBlock]$BUTTON_FUNCTION = { Get-BatteryReport }
New-Button 'Get battery report' $BUTTON_FUNCTION -Disabled (-not $IS_LAPTOP)
