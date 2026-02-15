New-Card 'Apps configuration'


[Windows.Controls.CheckBox]$CHECKBOX_Config_7zip = New-CheckBox '7-Zip' -Name '7-Zip' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_VLC = New-CheckBox 'VLC' -Name 'VLC' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_AnyDesk = New-CheckBox 'AnyDesk' -Name 'AnyDesk' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_qBittorrent = New-CheckBox 'qBittorrent' -Name 'qBittorrent' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_Edge = New-CheckBox 'Microsoft Edge' -Name 'Microsoft Edge' -Checked
[Windows.Controls.CheckBox]$CHECKBOX_Config_Chrome = New-CheckBox 'Google Chrome' -Name 'Google Chrome' -Checked


Set-Variable -Option Constant AppsConfigurationParameters (
    [Hashtable]@{
        '7zip'      = $CHECKBOX_Config_7zip
        VLC         = $CHECKBOX_Config_VLC
        AnyDesk     = $CHECKBOX_Config_AnyDesk
        qBittorrent = $CHECKBOX_Config_qBittorrent
        Edge        = $CHECKBOX_Config_Edge
        Chrome      = $CHECKBOX_Config_Chrome
    }
)

[ScriptBlock]$BUTTON_FUNCTION = {
    $CapturedAppsConfig = @{}
    foreach ($Entry in $AppsConfigurationParameters.GetEnumerator()) {
        $CapturedAppsConfig[$Entry.Key] = [PSCustomObject]@{ IsChecked = $Entry.Value.IsChecked; Tag = [String]$Entry.Value.Tag }
    }
    Start-AsyncOperation -Button $this { Set-AppsConfiguration @CapturedAppsConfig } -Variables @{
        CapturedAppsConfig = $CapturedAppsConfig
    }
}
New-Button 'Apply configuration' $BUTTON_FUNCTION
