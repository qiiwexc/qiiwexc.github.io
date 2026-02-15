New-Card 'Windows configuration'


[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsSecurity = New-CheckBox 'Improve security' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsPerformance = New-CheckBox 'Improve performance' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsBaseline = New-CheckBox 'Baseline configuration' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsAnnoyances = New-CheckBox 'Remove ads and annoyances' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsPrivacy = New-CheckBox 'Telemetry and privacy' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsLocalisation = New-CheckBox 'Keyboard layout; location'
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsPersonalisation = New-CheckBox 'Personalisation'


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

[ScriptBlock]$BUTTON_FUNCTION = {
    $CapturedWindowsConfig = @{}
    foreach ($Entry in $WindowsConfigurationParameters.GetEnumerator()) {
        $CapturedWindowsConfig[$Entry.Key] = [PSCustomObject]@{ IsChecked = $Entry.Value.IsChecked }
    }
    Start-AsyncOperation -Sender $this { Set-WindowsConfiguration @CapturedWindowsConfig } -Variables @{
        CapturedWindowsConfig = $CapturedWindowsConfig
    }
}
New-Button 'Apply configuration' $BUTTON_FUNCTION
