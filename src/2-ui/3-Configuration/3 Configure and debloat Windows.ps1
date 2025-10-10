New-GroupBox 'Configure and debloat Windows'


[ScriptBlock]$BUTTON_FUNCTION = { Start-WindowsDebloat -UsePreset $CHECKBOX_UseDebloatPreset.Checked -Personalisation $CHECKBOX_DebloatAndPersonalise.Checked -Silent $CHECKBOX_SilentlyRunDebloat.Checked }
New-Button 'Windows 10/11 debloat' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Checked
$CHECKBOX_UseDebloatPreset.Add_CheckStateChanged( {
        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_SilentlyRunDebloat
        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_DebloatAndPersonalise
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_DebloatAndPersonalise = New-CheckBox '+ Personalisation settings'

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = { Start-WinUtil -Personalisation $CHECKBOX_WinUtilPersonalisation.Checked -AutomaticallyApply $CHECKBOX_AutomaticallyRunWinUtil.Checked }
New-Button 'WinUtil' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_WinUtilPersonalisation = New-CheckBox '+ Personalisation settings'

[System.Windows.Forms.CheckBox]$CHECKBOX_AutomaticallyRunWinUtil = New-CheckBox 'Auto apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = { Start-OoShutUp10 -Execute $CHECKBOX_StartOoShutUp10.Checked -Silent ($CHECKBOX_StartOoShutUp10.Checked -and $CHECKBOX_SilentlyRunOoShutUp10.Checked) }
New-Button 'OOShutUp10++ privacy' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartOoShutUp10 = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartOoShutUp10.Add_CheckStateChanged( {
        Set-CheckboxState -Control $CHECKBOX_StartOoShutUp10 -Dependant $CHECKBOX_SilentlyRunOoShutUp10
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunOoShutUp10 = New-CheckBox 'Silently apply tweaks'
