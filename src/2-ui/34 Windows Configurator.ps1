New-GroupBox 'Windows configurator' 4


$BUTTON_FUNCTION = { Start-WinUtil -Apply:$CHECKBOX_SilentlyRunWinUtil.Checked }
New-Button 'WinUtil' $BUTTON_FUNCTION | Out-Null

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_SilentlyRunWinUtil = New-CheckBox 'Auto apply tweaks' -Disabled:$CHECKBOX_DISABLED
