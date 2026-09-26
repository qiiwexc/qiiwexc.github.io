Set-Variable -Option Constant TAB_HOME ([Hashtable]@{
        Tab   = 'Home'
        Cards = @(
            @{
                Card  = 'Updates'
                Items = @(
                    @{ Button = 'Update Windows'; Action = { Update-Windows } }
                    @{ Button = 'Update Store apps'; Action = { Start-AsyncOperation -Button $this { Update-MicrosoftStoreApps } } }
                    @{ Button = 'Update Microsoft Office'; Action = { Update-MicrosoftOffice } }
                )
            }
            @{
                Card  = 'Cleanup'
                Items = @(
                    @{ Button = 'Run cleanup'; Action = { Start-AsyncOperation -Button $this { Start-Cleanup } } }
                )
            }
            @{
                Card  = 'Activation'
                Items = @(
                    @{
                        Button  = 'MAS Activator'
                        Action  = {
                            $ActivateWindows = $CHECKBOXES.ActivateWindows.IsChecked
                            $ActivateOffice = $CHECKBOXES.ActivateOffice.IsChecked
                            Start-AsyncOperation -Button $this { Start-Activator -ActivateWindows:$ActivateWindows -ActivateOffice:$ActivateOffice } -Variables @{
                                ActivateWindows = $ActivateWindows
                                ActivateOffice  = $ActivateOffice
                            }
                        }
                        Options = @(
                            @{ CheckBox = 'Activate Windows silently'; Name = 'ActivateWindows' }
                            @{ CheckBox = 'Activate Office silently'; Name = 'ActivateOffice' }
                        )
                    }
                )
            }
            @{
                Card  = 'Defragmentation'
                Items = @(
                    @{ Button = 'Defragment drives'; Action = { Start-Defragmentation } }
                )
            }
            @{
                Card  = 'Hardware info'
                Items = @(
                    @{
                        Button             = 'CPU-Z'
                        Action             = {
                            $Execute = $CHECKBOXES.StartCpuZ.IsChecked
                            Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_CPU_Z}' -Sha256 '{SHA256_CPU_Z}' -Execute:$Execute } -Variables @{
                                Execute = $Execute
                            }
                        }
                        StartAfterDownload = @{ Name = 'StartCpuZ' }
                    }
                )
            }
            @{
                Card  = 'Bootable USB tools'
                Items = @(
                    @{
                        Button             = 'Ventoy'
                        Action             = {
                            $Execute = $CHECKBOXES.StartVentoy.IsChecked
                            $FileName = (Split-Path -Leaf '{URL_VENTOY}').Replace('-windows', '')
                            Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_VENTOY}' $FileName -Sha256 '{SHA256_VENTOY}' -Execute:$Execute } -Variables @{
                                Execute  = $Execute
                                FileName = $FileName
                            }
                        }
                        StartAfterDownload = @{ Name = 'StartVentoy' }
                    }
                    @{
                        Button             = 'Rufus'
                        Action             = {
                            $Execute = $CHECKBOXES.StartRufus.IsChecked
                            Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_RUFUS}' -Sha256 '{SHA256_RUFUS}' -Execute:$Execute -Params '-g' } -Variables @{
                                Execute = $Execute
                            }
                        }
                        StartAfterDownload = @{ Name = 'StartRufus' }
                    }
                )
            }
        )
    })
