# The checkbox behind each of Set-AppsConfiguration's parameters
Set-Variable -Option Constant APPS_CONFIGURATION_CHECKBOXES ([Hashtable]@{
        '7zip'      = 'Config_7zip'
        VLC         = 'Config_VLC'
        AnyDesk     = 'Config_AnyDesk'
        qBittorrent = 'Config_qBittorrent'
        Edge        = 'Config_Edge'
        Chrome      = 'Config_Chrome'
    })

# The checkbox behind each of Set-WindowsConfiguration's parameters
Set-Variable -Option Constant WINDOWS_CONFIGURATION_CHECKBOXES ([Hashtable]@{
        Security        = 'Config_WindowsSecurity'
        Performance     = 'Config_WindowsPerformance'
        Baseline        = 'Config_WindowsBaseline'
        Annoyances      = 'Config_WindowsAnnoyances'
        Privacy         = 'Config_WindowsPrivacy'
        Localization    = 'Config_WindowsLocalization'
        Personalization = 'Config_WindowsPersonalization'
    })

# There is nothing to apply without at least one configuration selected
Set-Variable -Option Constant APPS_CONFIGURATION_ON_CLICK ([ScriptBlock] {
        Set-ButtonEnabled $BUTTONS.ApplyAppsConfiguration ([Bool]@($APPS_CONFIGURATION_CHECKBOXES.Values | Where-Object { $CHECKBOXES[$_].IsChecked }).Count)
    })

Set-Variable -Option Constant WINDOWS_CONFIGURATION_ON_CLICK ([ScriptBlock] {
        Set-ButtonEnabled $BUTTONS.ApplyWindowsConfiguration ([Bool]@($WINDOWS_CONFIGURATION_CHECKBOXES.Values | Where-Object { $CHECKBOXES[$_].IsChecked }).Count)
    })

Set-Variable -Option Constant TAB_CONFIGURATION ([Hashtable]@{
        Tab   = 'Configuration'
        Cards = @(
            @{
                Card  = 'Debloat Windows'
                Items = @(
                    @{
                        Button  = 'Windows 10/11 debloat'
                        Action  = {
                            $UsePreset = $CHECKBOXES.UseDebloatPreset.IsChecked
                            $Personalization = $CHECKBOXES.DebloatAndPersonalise.IsChecked
                            $Silent = $CHECKBOXES.SilentlyRunDebloat.IsChecked
                            Start-AsyncOperation -Button $this { Start-WindowsDebloat -UsePreset:$UsePreset -Personalization:$Personalization -Silent:$Silent } -Variables @{
                                UsePreset       = $UsePreset
                                Personalization = $Personalization
                                Silent          = $Silent
                            }
                        }
                        Options = @(
                            @{
                                CheckBox = 'Use custom preset'
                                Name     = 'UseDebloatPreset'
                                Checked  = $True
                                OnClick  = {
                                    Set-CheckboxState -Control $this -Dependant $CHECKBOXES.SilentlyRunDebloat
                                    Set-CheckboxState -Control $this -Dependant $CHECKBOXES.DebloatAndPersonalise
                                }
                            }
                            @{ CheckBox = '+ Personalization settings'; Name = 'DebloatAndPersonalise' }
                            @{ CheckBox = 'Silently apply tweaks'; Name = 'SilentlyRunDebloat' }
                        )
                    }
                    @{
                        Button             = 'OOShutUp10++ privacy'
                        Action             = {
                            $Execute = $CHECKBOXES.StartOoShutUp10.IsChecked
                            $Silent = $CHECKBOXES.StartOoShutUp10.IsChecked -and $CHECKBOXES.SilentlyRunOoShutUp10.IsChecked
                            Start-AsyncOperation -Button $this { Start-OoShutUp10 -Execute:$Execute -Silent:$Silent } -Variables @{
                                Execute = $Execute
                                Silent  = $Silent
                            }
                        }
                        StartAfterDownload = @{
                            Name    = 'StartOoShutUp10'
                            OnClick = { Set-CheckboxState -Control $this -Dependant $CHECKBOXES.SilentlyRunOoShutUp10 }
                        }
                        Options            = @(
                            @{ CheckBox = 'Silently apply tweaks'; Name = 'SilentlyRunOoShutUp10' }
                        )
                    }
                    @{ Button = 'WinUtil'; Action = { Start-AsyncOperation -Button $this { Start-WinUtil } } }
                )
            }
            @{
                Card  = 'Windows configuration'
                Items = @(
                    @{ CheckBox = 'Improve security'; Name = 'Config_WindowsSecurity'; Checked = $True; OnClick = $WINDOWS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Improve performance'; Name = 'Config_WindowsPerformance'; Checked = $True; OnClick = $WINDOWS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Baseline configuration'; Name = 'Config_WindowsBaseline'; Checked = $True; OnClick = $WINDOWS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Remove ads and annoyances'; Name = 'Config_WindowsAnnoyances'; Checked = $True; OnClick = $WINDOWS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Telemetry and privacy'; Name = 'Config_WindowsPrivacy'; Checked = $True; OnClick = $WINDOWS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Keyboard layout; location'; Name = 'Config_WindowsLocalization'; OnClick = $WINDOWS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Personalization'; Name = 'Config_WindowsPersonalization'; OnClick = $WINDOWS_CONFIGURATION_ON_CLICK }
                    @{
                        Button = 'Apply configuration'
                        Name   = 'ApplyWindowsConfiguration'
                        Action = {
                            $CapturedWindowsConfig = @{}
                            foreach ($Entry in $WINDOWS_CONFIGURATION_CHECKBOXES.GetEnumerator()) {
                                $CapturedWindowsConfig[$Entry.Key] = [PSCustomObject]@{ IsChecked = $CHECKBOXES[$Entry.Value].IsChecked }
                            }
                            Start-AsyncOperation -Button $this { Set-WindowsConfiguration @CapturedWindowsConfig } -Variables @{
                                CapturedWindowsConfig = $CapturedWindowsConfig
                            }
                        }
                    }
                )
            }
            @{
                Card  = 'Apps configuration'
                Items = @(
                    @{ CheckBox = '7-Zip'; Name = 'Config_7zip'; Tag = '7-Zip'; Checked = $True; OnClick = $APPS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'VLC'; Name = 'Config_VLC'; Tag = 'VLC'; Checked = $True; OnClick = $APPS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'AnyDesk'; Name = 'Config_AnyDesk'; Tag = 'AnyDesk'; Checked = $True; OnClick = $APPS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'qBittorrent'; Name = 'Config_qBittorrent'; Tag = 'qBittorrent'; Checked = $True; OnClick = $APPS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Microsoft Edge'; Name = 'Config_Edge'; Tag = 'Microsoft Edge'; Checked = $True; OnClick = $APPS_CONFIGURATION_ON_CLICK }
                    @{ CheckBox = 'Google Chrome'; Name = 'Config_Chrome'; Tag = 'Google Chrome'; Checked = $True; OnClick = $APPS_CONFIGURATION_ON_CLICK }
                    @{
                        Button = 'Apply configuration'
                        Name   = 'ApplyAppsConfiguration'
                        Action = {
                            $CapturedAppsConfig = @{}
                            foreach ($Entry in $APPS_CONFIGURATION_CHECKBOXES.GetEnumerator()) {
                                $CheckBox = $CHECKBOXES[$Entry.Value]
                                $CapturedAppsConfig[$Entry.Key] = [PSCustomObject]@{ IsChecked = $CheckBox.IsChecked; Tag = [String]$CheckBox.Tag }
                            }
                            Start-AsyncOperation -Button $this { Set-AppsConfiguration @CapturedAppsConfig } -Variables @{
                                CapturedAppsConfig = $CapturedAppsConfig
                            }
                        }
                    }
                )
            }
        )
    })
