New-Card 'Essentials'


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartSDI.IsChecked
    Start-AsyncOperation -Button $this { Start-SnappyDriverInstaller -Execute:$Execute } -Variables @{
        Execute = $Execute
    }
}
New-Button 'Snappy Driver Installer' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartOfficeInstaller.IsChecked
    Start-AsyncOperation -Button $this { Install-MicrosoftOffice -Execute:$Execute } -Variables @{
        Execute = $Execute
    }
}
New-Button 'Office Installer' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartUnchecky.IsChecked
    $Silent = $CHECKBOX_SilentlyInstallUnchecky.IsChecked
    Start-AsyncOperation -Button $this { Install-Unchecky -Execute:$Execute -Silent:$Silent } -Variables @{
        Execute = $Execute
        Silent  = $Silent
    }
}
New-Button 'Unchecky' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartUnchecky.Add_Checked( {
        Set-CheckboxState -Control $CHECKBOX_StartUnchecky -Dependant $CHECKBOX_SilentlyInstallUnchecky
    } )
$CHECKBOX_StartUnchecky.Add_Unchecked( {
        Set-CheckboxState -Control $CHECKBOX_StartUnchecky -Dependant $CHECKBOX_SilentlyInstallUnchecky
    } )

[Windows.Controls.CheckBox]$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Checked
