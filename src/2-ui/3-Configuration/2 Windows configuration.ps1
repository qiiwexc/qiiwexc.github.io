New-GroupBox 'Windows configuration'

[Switch]$PAD_CHECKBOXES = $False


[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsSecurity = New-CheckBox 'Improve security' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPerformance = New-CheckBox 'Improve performance' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsBaseline = New-CheckBox 'Baseline configuration' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsAnnoyances = New-CheckBox 'Remove ads and annoyances' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPrivacy = New-CheckBox 'Telemetry and privacy' -Checked

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsLocalisation = New-CheckBox 'Keyboard layout; location'

[Windows.Forms.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'


Set-Variable -Option Constant WindowsConfigurationParameters (
    [Hashtable]@{
        Security        = $CHECKBOX_Config_WindowsSecurity
        Performance     = $CHECKBOX_Config_WindowsPerformance
        Baseline        = $CHECKBOX_Config_WindowsBaseline
        Annoyances      = $CHECKBOX_Config_WindowsAnnoyances
        Privacy         = $CHECKBOX_Config_WindowsPrivacy
        Localisation    = $CHECKBOX_Config_WindowsLocalisation
        Personalisation = $CHECKBOX_Config_WindowsPersonalisation
    }
)

[ScriptBlock]$BUTTON_FUNCTION = { Set-WindowsConfiguration @WindowsConfigurationParameters }
New-Button 'Apply configuration' $BUTTON_FUNCTION
