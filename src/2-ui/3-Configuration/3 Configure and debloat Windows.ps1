New-Card 'Debloat Windows'


[ScriptBlock]$BUTTON_FUNCTION = {
    $UsePreset = $CHECKBOX_UseDebloatPreset.IsChecked
    $Personalisation = $CHECKBOX_DebloatAndPersonalise.IsChecked
    $Silent = $CHECKBOX_SilentlyRunDebloat.IsChecked
    Start-AsyncOperation -Button $this { Start-WindowsDebloat -UsePreset:$UsePreset -Personalisation:$Personalisation -Silent:$Silent } -Variables @{
        UsePreset       = $UsePreset
        Personalisation = $Personalisation
        Silent          = $Silent
    }
}
New-Button 'Windows 10/11 debloat' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_UseDebloatPreset = New-CheckBox 'Use custom preset' -Checked
$CHECKBOX_UseDebloatPreset.Add_Checked( {
        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_SilentlyRunDebloat
        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_DebloatAndPersonalise
    } )
$CHECKBOX_UseDebloatPreset.Add_Unchecked( {
        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_SilentlyRunDebloat
        Set-CheckboxState -Control $CHECKBOX_UseDebloatPreset -Dependant $CHECKBOX_DebloatAndPersonalise
    } )

[Windows.Controls.CheckBox]$CHECKBOX_DebloatAndPersonalise = New-CheckBox '+ Personalisation settings'

[Windows.Controls.CheckBox]$CHECKBOX_SilentlyRunDebloat = New-CheckBox 'Silently apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartOoShutUp10.IsChecked
    $Silent = $CHECKBOX_StartOoShutUp10.IsChecked -and $CHECKBOX_SilentlyRunOoShutUp10.IsChecked
    Start-AsyncOperation -Button $this { Start-OoShutUp10 -Execute:$Execute -Silent:$Silent } -Variables @{
        Execute = $Execute
        Silent  = $Silent
    }
}
New-Button 'OOShutUp10++ privacy' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartOoShutUp10 = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartOoShutUp10.Add_Checked( {
        Set-CheckboxState -Control $CHECKBOX_StartOoShutUp10 -Dependant $CHECKBOX_SilentlyRunOoShutUp10
    } )
$CHECKBOX_StartOoShutUp10.Add_Unchecked( {
        Set-CheckboxState -Control $CHECKBOX_StartOoShutUp10 -Dependant $CHECKBOX_SilentlyRunOoShutUp10
    } )

[Windows.Controls.CheckBox]$CHECKBOX_SilentlyRunOoShutUp10 = New-CheckBox 'Silently apply tweaks'


[ScriptBlock]$BUTTON_FUNCTION = { Start-AsyncOperation -Button $this { Start-WinUtil } }
New-Button 'WinUtil' $BUTTON_FUNCTION
