New-GroupBox 'Debloat Windows and Privacy'


$BUTTON_FUNCTION = { Start-WindowsDebloat }
New-Button -UAC 'Windows 10/11 debloat' $BUTTON_FUNCTION | Out-Null


$BUTTON_FUNCTION = { Start-ShutUp10 -Execute:$CHECKBOX_StartShutUp10.Checked -Silent:($CHECKBOX_StartShutUp10.Checked -and $CHECKBOX_SilentlyRunShutUp10.Checked) }
$BUTTON_StartShutUp10 = New-Button -UAC 'ShutUp10++ privacy' $BUTTON_FUNCTION

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
$CHECKBOX_StartShutUp10 = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartShutUp10.Add_CheckStateChanged( {
    $CHECKBOX_SilentlyRunShutUp10.Enabled = $CHECKBOX_StartShutUp10.Checked
    $BUTTON_StartShutUp10.Text = "ShutUp10++ privacy$(if ($CHECKBOX_StartShutUp10.Checked) { $REQUIRES_ELEVATION })"
} )

$CHECKBOX_DISABLED = $PS_VERSION -le 2
$CHECKBOX_SilentlyRunShutUp10 = New-CheckBox 'Silently apply tweaks' -Disabled:$CHECKBOX_DISABLED
