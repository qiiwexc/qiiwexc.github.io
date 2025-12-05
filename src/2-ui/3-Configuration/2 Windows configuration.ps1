New-GroupBox 'Windows configuration'

[Switch]$PAD_CHECKBOXES = $False


[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBase = New-CheckBox 'Base config and privacy' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_PowerScheme = New-CheckBox 'Set power scheme' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsSearch = New-CheckBox 'Configure search index' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_FileAssociations = New-CheckBox 'Set file associations'

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'


Set-Variable -Option Constant WindowsConfigurationParameters (
    [Hashtable]@{
        Base             = $CHECKBOX_Config_WindowsBase
        PowerScheme      = $CHECKBOX_Config_PowerScheme
        Search           = $CHECKBOX_Config_WindowsSearch
        FileAssociations = $CHECKBOX_Config_FileAssociations
        Personalisation  = $CHECKBOX_Config_WindowsPersonalisation
    }
)
[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration @WindowsConfigurationParameters }
New-Button 'Apply configuration' $BUTTON_FUNCTION
