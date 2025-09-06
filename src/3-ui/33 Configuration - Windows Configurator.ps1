New-GroupBox 'Windows Configurator'


$BUTTON_FUNCTION = { Start-WinUtil -Apply:$CHECKBOX_SilentlyRunWinUtil.Checked }
New-Button -UAC 'WinUtil' $BUTTON_FUNCTION > $Null

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_SilentlyRunWinUtil = New-CheckBox 'Auto apply tweaks' -Disabled:$CHECKBOX_DISABLED
