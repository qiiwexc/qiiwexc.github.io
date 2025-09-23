New-GroupBox 'Debloat Windows and privacy' 5


[ScriptBlock]$BUTTON_FUNCTION = { Start-WindowsDebloat }
New-Button 'Windows 10/11 debloat' $BUTTON_FUNCTION

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[Boolean]$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
[System.Windows.Forms.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_UseDebloatPreset.Add_CheckStateChanged( {
    $CHECKBOX_SilentlyRunDebloat.Enabled = $CHECKBOX_UseDebloatPreset.Checked
} )

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks' -Disabled:$CHECKBOX_DISABLED


[ScriptBlock]$BUTTON_FUNCTION = { Start-ShutUp10 -Execute:$CHECKBOX_StartShutUp10.Checked -Silent:($CHECKBOX_StartShutUp10.Checked -and $CHECKBOX_SilentlyRunShutUp10.Checked) }
New-Button 'ShutUp10++ privacy' $BUTTON_FUNCTION

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[Boolean]$CHECKBOX_CHECKED = !$CHECKBOX_DISABLED
[System.Windows.Forms.CheckBox]$CHECKBOX_StartShutUp10 = New-CheckBoxRunAfterDownload -Disabled:$CHECKBOX_DISABLED -Checked:$CHECKBOX_CHECKED
$CHECKBOX_StartShutUp10.Add_CheckStateChanged( {
    $CHECKBOX_SilentlyRunShutUp10.Enabled = $CHECKBOX_StartShutUp10.Checked
} )

[Boolean]$CHECKBOX_DISABLED = $PS_VERSION -le 2
[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunShutUp10 = New-CheckBox 'Silently apply tweaks' -Disabled:$CHECKBOX_DISABLED
