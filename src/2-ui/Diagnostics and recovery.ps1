Set-Variable -Option Constant TAB_DIAGNOSTICS ([Hashtable]@{
        Tab   = 'Diagnostics and recovery'
        Cards = @(
            @{
                Card  = 'Windows diagnostics'
                Items = @(
                    @{ Button = 'Run DISM and SFC'; Action = { Start-AsyncOperation -Button $this { Start-WindowsDiagnostics } } }
                )
            }
            @{
                Card  = 'HDD diagnostics'
                Items = @(
                    @{
                        Button  = 'Check Disk'
                        Action  = {
                            $ScheduleFullScan = $CHECKBOXES.ChkDskScheduleFullScan.IsChecked
                            Start-AsyncOperation -Button $this { Start-ChkDsk -ScheduleFullScan:$ScheduleFullScan } -Variables @{
                                ScheduleFullScan = $ScheduleFullScan
                            }
                        }
                        Options = @(
                            @{ CheckBox = 'Run full scan after restart'; Name = 'ChkDskScheduleFullScan' }
                        )
                    }
                    @{
                        Button             = 'Victoria'
                        Action             = {
                            $Execute = $CHECKBOXES.StartVictoria.IsChecked
                            Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_VICTORIA}' -Sha256 '{SHA256_VICTORIA}' -Execute:$Execute } -Variables @{
                                Execute = $Execute
                            }
                        }
                        StartAfterDownload = @{ Name = 'StartVictoria' }
                    }
                )
            }
            @{
                Card  = 'RAM diagnostics'
                Items = @(
                    @{ Button = 'Memory Diagnostic'; Action = { Start-MemoryDiagnostics } }
                )
            }
            @{
                Card  = 'Battery report'
                Items = @(
                    @{ Button = 'Get battery report'; Disabled = -not $IS_LAPTOP; Action = { Start-AsyncOperation -Button $this { Get-BatteryReport } } }
                )
            }
            @{
                Card  = 'Live CDs'
                Items = @(
                    @{ Button = 'Download Windows PE'; Browser = $True; Action = { Open-InBrowser '{URL_WINDOWS_PE}' } }
                    @{ Button = 'Download SystemRescue'; Browser = $True; Action = { Open-InBrowser '{URL_SYSTEM_RESCUE}' } }
                )
            }
            @{
                Card  = 'Windows disinfection'
                Items = @(
                    @{ Button = 'Download TronScript'; Browser = $True; Action = { Open-InBrowser '{URL_TRONSCRIPT}' } }
                )
            }
        )
    })
