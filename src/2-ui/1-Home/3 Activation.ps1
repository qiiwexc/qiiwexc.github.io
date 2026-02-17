New-Card 'Activation'


[ScriptBlock]$BUTTON_FUNCTION = {
    $ActivateWindows = $CHECKBOX_ActivateWindows.IsChecked
    $ActivateOffice = $CHECKBOX_ActivateOffice.IsChecked
    Start-Activator -ActivateWindows:$ActivateWindows -ActivateOffice:$ActivateOffice
}
New-Button 'MAS Activator' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_ActivateWindows = New-CheckBox 'Activate Windows silently'

[Windows.Controls.CheckBox]$CHECKBOX_ActivateOffice = New-CheckBox 'Activate Office silently'
