# The order Ninite's query and the installer's file name list the apps in
Set-Variable -Option Constant NINITE_CHECKBOX_NAMES ([String[]]@(
        'Ninite_7zip',
        'Ninite_VLC',
        'Ninite_AnyDesk',
        'Ninite_Chrome',
        'Ninite_Firefox',
        'Ninite_qBittorrent',
        'Ninite_Malwarebytes'
    ))

Set-Variable -Option Constant NINITE_ON_CLICK ([ScriptBlock] {
        Set-NiniteButtonState @($NINITE_CHECKBOX_NAMES | ForEach-Object { $CHECKBOXES[$_] }) $CHECKBOXES.StartNinite
    })

Set-Variable -Option Constant TAB_INSTALLS ([Hashtable]@{
        Tab   = 'Installs'
        Cards = @(
            @{
                Card  = 'Ninite'
                Items = @(
                    @{ CheckBox = 'Google Chrome'; Name = 'Ninite_Chrome'; Tag = 'chrome'; Checked = $True; OnClick = $NINITE_ON_CLICK }
                    @{ CheckBox = 'Mozilla Firefox'; Name = 'Ninite_Firefox'; Tag = 'firefox'; Checked = $True; OnClick = $NINITE_ON_CLICK }
                    @{ CheckBox = '7-Zip'; Name = 'Ninite_7zip'; Tag = '7zip'; Checked = $True; OnClick = $NINITE_ON_CLICK }
                    @{ CheckBox = 'VLC'; Name = 'Ninite_VLC'; Tag = 'vlc'; Checked = $True; OnClick = $NINITE_ON_CLICK }
                    @{ CheckBox = 'AnyDesk'; Name = 'Ninite_AnyDesk'; Tag = 'anydesk'; Checked = $True; OnClick = $NINITE_ON_CLICK }
                    @{ CheckBox = 'qBittorrent'; Name = 'Ninite_qBittorrent'; Tag = 'qbittorrent'; OnClick = $NINITE_ON_CLICK }
                    @{ CheckBox = 'Malwarebytes'; Name = 'Ninite_Malwarebytes'; Tag = 'malwarebytes'; OnClick = $NINITE_ON_CLICK }
                    @{
                        Button             = 'Install selected'
                        Action             = {
                            $CapturedCheckboxes = $NINITE_CHECKBOX_NAMES | ForEach-Object { $CHECKBOXES[$_] } | ForEach-Object { [PSCustomObject]@{ IsChecked = $_.IsChecked; Tag = [String]$_.Tag; Content = [String]$_.Content } }
                            $Execute = $CHECKBOXES.StartNinite.IsChecked
                            $OpenInBrowser = -not $CHECKBOXES.StartNinite.IsEnabled
                            Start-AsyncOperation -Button $this { Get-NiniteInstaller $CapturedCheckboxes -OpenInBrowser:$OpenInBrowser -Execute:$Execute } -Variables @{
                                CapturedCheckboxes = $CapturedCheckboxes
                                Execute            = $Execute
                                OpenInBrowser      = $OpenInBrowser
                            }
                        }
                        StartAfterDownload = @{ Name = 'StartNinite' }
                    }
                    @{
                        Button  = 'More'
                        Browser = $True
                        Action  = { Get-NiniteInstaller @($NINITE_CHECKBOX_NAMES | ForEach-Object { $CHECKBOXES[$_] }) -OpenInBrowser }
                    }
                )
            }
            @{
                Card  = 'Essentials'
                Items = @(
                    @{
                        Button             = 'Snappy Driver Installer'
                        Action             = {
                            $Execute = $CHECKBOXES.StartSDI.IsChecked
                            Start-AsyncOperation -Button $this { Start-SnappyDriverInstaller -Execute:$Execute } -Variables @{
                                Execute = $Execute
                            }
                        }
                        StartAfterDownload = @{ Name = 'StartSDI' }
                    }
                    @{
                        Button             = 'Office Installer'
                        Action             = {
                            $Execute = $CHECKBOXES.StartOfficeInstaller.IsChecked
                            Start-AsyncOperation -Button $this { Install-MicrosoftOffice -Execute:$Execute } -Variables @{
                                Execute = $Execute
                            }
                        }
                        StartAfterDownload = @{ Name = 'StartOfficeInstaller' }
                    }
                    @{
                        Button             = 'Unchecky'
                        Action             = {
                            $Execute = $CHECKBOXES.StartUnchecky.IsChecked
                            $Silent = $CHECKBOXES.SilentlyInstallUnchecky.IsChecked
                            Start-AsyncOperation -Button $this { Install-Unchecky -Execute:$Execute -Silent:$Silent } -Variables @{
                                Execute = $Execute
                                Silent  = $Silent
                            }
                        }
                        StartAfterDownload = @{
                            Name    = 'StartUnchecky'
                            OnClick = { Set-CheckboxState -Control $this -Dependant $CHECKBOXES.SilentlyInstallUnchecky }
                        }
                        Options            = @(
                            @{ CheckBox = 'Install silently'; Name = 'SilentlyInstallUnchecky'; Checked = $True }
                        )
                    }
                )
            }
            @{
                Card  = 'Windows images'
                Items = @(
                    @{ Button = 'Windows 11'; Browser = $True; Action = { Open-InBrowser '{URL_WINDOWS_11}' } }
                    @{ Button = 'Windows 10'; Browser = $True; Action = { Open-InBrowser '{URL_WINDOWS_10}' } }
                    @{ Button = 'Windows 7'; Browser = $True; Action = { Open-InBrowser '{URL_WINDOWS_7}' } }
                )
            }
        )
    })
