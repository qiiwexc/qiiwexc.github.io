New-GroupBox 'Windows configurator' 4


[ScriptBlock]$BUTTON_FUNCTION = { Start-WinUtil -Apply:$CHECKBOX_SilentlyRunWinUtil.Checked }
New-Button 'WinUtil' $BUTTON_FUNCTION

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunWinUtil = New-CheckBox 'Auto apply tweaks' -Disabled:$CHECKBOX_DISABLED
