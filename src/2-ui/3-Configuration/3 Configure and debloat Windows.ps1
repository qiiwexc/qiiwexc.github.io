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


[ScriptBlock]$BUTTON_FUNCTION = { Start-ShutUp10 -Execute:$CHECKBOX_StartShutUp10.Checked -Silent:($CHECKBOX_StartShutUp10.Checked -and $CHECKBOX_SilentlyRunShutUp10.Checked) }
New-Button 'ShutUp10++ privacy' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartShutUp10 = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartShutUp10.Add_CheckStateChanged( {
        $CHECKBOX_SilentlyRunShutUp10.Enabled = $CHECKBOX_StartShutUp10.Checked
        if (-not $CHECKBOX_SilentlyRunShutUp10.Enabled) {
            $CHECKBOX_SilentlyRunShutUp10.Checked = $CHECKBOX_SilentlyRunShutUp10.Enabled
        }
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyRunShutUp10 = New-CheckBox 'Silently apply tweaks'
