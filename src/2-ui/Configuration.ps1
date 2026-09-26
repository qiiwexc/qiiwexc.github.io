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

Set-Variable -Option Constant TAB_CONFIGURATION ([Hashtable]@{
        Tab   = 'Configuration'
        Cards = @(
            @{
                Card  = 'Apps configuration'
                Items = @(
                    @{ CheckBox = '7-Zip'; Name = 'Config_7zip'; Tag = '7-Zip'; Checked = $True }
                    @{ CheckBox = 'VLC'; Name = 'Config_VLC'; Tag = 'VLC'; Checked = $True }
                    @{ CheckBox = 'AnyDesk'; Name = 'Config_AnyDesk'; Tag = 'AnyDesk'; Checked = $True }
                    @{ CheckBox = 'qBittorrent'; Name = 'Config_qBittorrent'; Tag = 'qBittorrent'; Checked = $True }
                    @{ CheckBox = 'Microsoft Edge'; Name = 'Config_Edge'; Tag = 'Microsoft Edge'; Checked = $True }
                    @{ CheckBox = 'Google Chrome'; Name = 'Config_Chrome'; Tag = 'Google Chrome'; Checked = $True }
                    @{
                        Button = 'Apply configuration'
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
            @{
                Card  = 'Windows configuration'
                Items = @(
                    @{ CheckBox = 'Improve security'; Name = 'Config_WindowsSecurity'; Checked = $True }
                    @{ CheckBox = 'Improve performance'; Name = 'Config_WindowsPerformance'; Checked = $True }
                    @{ CheckBox = 'Baseline configuration'; Name = 'Config_WindowsBaseline'; Checked = $True }
                    @{ CheckBox = 'Remove ads and annoyances'; Name = 'Config_WindowsAnnoyances'; Checked = $True }
                    @{ CheckBox = 'Telemetry and privacy'; Name = 'Config_WindowsPrivacy'; Checked = $True }
                    @{ CheckBox = 'Keyboard layout; location'; Name = 'Config_WindowsLocalization' }
                    @{ CheckBox = 'Personalization'; Name = 'Config_WindowsPersonalization' }
                    @{
                        Button = 'Apply configuration'
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
                Card  = 'Alternative DNS'
                Items = @(
                    @{
                        Button  = 'Setup CloudFlare DNS'
                        Action  = {
                            $MalwareProtection = $CHECKBOXES.CloudFlareAntiMalware.IsChecked
                            $FamilyFriendly = $CHECKBOXES.CloudFlareFamilyFriendly.IsChecked
                            Start-AsyncOperation -Button $this { Set-CloudFlareDNS -MalwareProtection:$MalwareProtection -FamilyFriendly:$FamilyFriendly } -Variables @{
                                MalwareProtection = $MalwareProtection
                                FamilyFriendly    = $FamilyFriendly
                            }
                        }
                        Options = @(
                            @{
                                CheckBox = 'Malware protection'
                                Name     = 'CloudFlareAntiMalware'
                                Checked  = $True
                                OnClick  = { Set-CheckboxState -Control $this -Dependant $CHECKBOXES.CloudFlareFamilyFriendly }
                            }
                            @{ CheckBox = 'Adult content filtering'; Name = 'CloudFlareFamilyFriendly' }
                        )
                    }
                )
            }
        )
    })
