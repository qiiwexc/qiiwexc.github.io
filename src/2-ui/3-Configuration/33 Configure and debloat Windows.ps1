New-GroupBox 'Configure and debloat Windows'


[ScriptBlock]$BUTTON_FUNCTION = { Start-WindowsDebloat -UsePreset:$CHECKBOX_UseDebloatPreset.Checked -Silent:$CHECKBOX_SilentlyRunDebloat.Checked }
New-Button 'Windows 10/11 debloat' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Checked
$CHECKBOX_UseDebloatPreset.Add_CheckStateChanged( {
        $CHECKBOX_SilentlyRunDebloat.Enabled = $CHECKBOX_UseDebloatPreset.Checked
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = { Start-WinUtil -Apply:$CHECKBOX_SilentlyRunWinUtil.Checked }
New-Button 'WinUtil' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunWinUtil = New-CheckBox 'Auto apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = { Start-ShutUp10 -Execute:$CHECKBOX_StartShutUp10.Checked -Silent:($CHECKBOX_StartShutUp10.Checked -and $CHECKBOX_SilentlyRunShutUp10.Checked) }
New-Button 'ShutUp10++ privacy' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartShutUp10 = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartShutUp10.Add_CheckStateChanged( {
        $CHECKBOX_SilentlyRunShutUp10.Enabled = $CHECKBOX_StartShutUp10.Checked
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunShutUp10 = New-CheckBox 'Silently apply tweaks'
