New-GroupBox 'Configure and debloat Windows'


[ScriptBlock]$BUTTON_FUNCTION = { Start-WindowsDebloat -UsePreset:$CHECKBOX_UseDebloatPreset.Checked -Personalisation:$CHECKBOX_DebloatAndPersonalise.Checked -Silent:$CHECKBOX_SilentlyRunDebloat.Checked }
New-Button 'Windows 10/11 debloat' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Checked
$CHECKBOX_UseDebloatPreset.Add_CheckStateChanged( {
        $CHECKBOX_SilentlyRunDebloat.Enabled = $CHECKBOX_UseDebloatPreset.Checked
        if (-not $CHECKBOX_SilentlyRunDebloat.Enabled) {
            $CHECKBOX_SilentlyRunDebloat.Checked = $CHECKBOX_SilentlyRunDebloat.Enabled
        }
        $CHECKBOX_DebloatAndPersonalise.Enabled = $CHECKBOX_UseDebloatPreset.Checked
        if (-not $CHECKBOX_DebloatAndPersonalise.Enabled) {
            $CHECKBOX_DebloatAndPersonalise.Checked = $CHECKBOX_DebloatAndPersonalise.Enabled
        }
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_DebloatAndPersonalise = New-CheckBox '+ Personalisation settings'

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = { Start-WinUtil -Personalisation:$CHECKBOX_WinUtilPersonalisation.Checked -AutomaticallyApply:$CHECKBOX_AutomaticallyRunWinUtil.Checked }
New-Button 'WinUtil' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_WinUtilPersonalisation = New-CheckBox '+ Personalisation settings'

[System.Windows.Forms.CheckBox]$CHECKBOX_AutomaticallyRunWinUtil = New-CheckBox 'Auto apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = { Start-OoShutUp10 -Execute:$CHECKBOX_StartOoShutUp10.Checked -Silent:($CHECKBOX_StartOoShutUp10.Checked -and $CHECKBOX_SilentlyRunOoShutUp10.Checked) }
New-Button 'OOShutUp10++ privacy' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartOoShutUp10 = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartOoShutUp10.Add_CheckStateChanged( {
        $CHECKBOX_SilentlyRunOoShutUp10.Enabled = $CHECKBOX_StartOoShutUp10.Checked
        if (-not $CHECKBOX_SilentlyRunOoShutUp10.Enabled) {
            $CHECKBOX_SilentlyRunOoShutUp10.Checked = $CHECKBOX_SilentlyRunOoShutUp10.Enabled
        }
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunOoShutUp10 = New-CheckBox 'Silently apply tweaks'
