New-Card 'Windows configuration'


[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsSecurity = New-CheckBox 'Improve security' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsPerformance = New-CheckBox 'Improve performance' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsBaseline = New-CheckBox 'Baseline configuration' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsAnnoyances = New-CheckBox 'Remove ads and annoyances' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsPrivacy = New-CheckBox 'Telemetry and privacy' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsLocalization = New-CheckBox 'Keyboard layout; location'
[Windows.Controls.CheckBox]$CHECKBOX_Config_WindowsPersonalization = New-CheckBox 'Personalization'


Set-Variable -Option Constant WindowsConfigurationParameters (
    [Hashtable]@{
        Security        = $CHECKBOX_Config_WindowsSecurity
        Performance     = $CHECKBOX_Config_WindowsPerformance
        Baseline        = $CHECKBOX_Config_WindowsBaseline
        Annoyances      = $CHECKBOX_Config_WindowsAnnoyances
        Privacy         = $CHECKBOX_Config_WindowsPrivacy
        Localization    = $CHECKBOX_Config_WindowsLocalization
        Personalization = $CHECKBOX_Config_WindowsPersonalization
    }
)

[ScriptBlock]$BUTTON_FUNCTION = {
    $CapturedWindowsConfig = @{}
    foreach ($Entry in $WindowsConfigurationParameters.GetEnumerator()) {
        $CapturedWindowsConfig[$Entry.Key] = [PSCustomObject]@{ IsChecked = $Entry.Value.IsChecked }
    }
    Start-AsyncOperation -Button $this { Set-WindowsConfiguration @CapturedWindowsConfig } -Variables @{
        CapturedWindowsConfig = $CapturedWindowsConfig
    }
}
New-Button 'Apply configuration' $BUTTON_FUNCTION
