New-GroupBox 'Windows configuration'

[Switch]$PAD_CHECKBOXES = $False


[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBase = New-CheckBox 'Base config and privacy' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_PowerScheme = New-CheckBox 'Set power scheme' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsSearch = New-CheckBox 'Configure search index' -Checked

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_FileAssociations = New-CheckBox 'Set file associations'

[System.Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'


Set-Variable -Option Constant WindowsConfigurationParameters @{
    Base             = $CHECKBOX_Config_WindowsBase
    PowerScheme      = $CHECKBOX_Config_PowerScheme
    Search           = $CHECKBOX_Config_WindowsSearch
    FileAssociations = $CHECKBOX_Config_FileAssociations
    Personalisation  = $CHECKBOX_Config_WindowsPersonalisation
}
[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration @WindowsConfigurationParameters }
New-Button 'Apply configuration' $BUTTON_FUNCTION
