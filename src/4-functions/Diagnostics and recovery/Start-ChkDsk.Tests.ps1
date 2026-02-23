BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'
    . '.\src\4-functions\App lifecycle\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TestDrive:\AppDir')

    Set-Variable -Option Constant TestLogPath ([String]"$PATH_APP_DIR\chkdsk.log")
}

Describe 'Start-ChkDsk' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Initialize-AppDirectory {}
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock Write-ActivityCompleted {}
        Mock chkdsk { return @('The type of the file system is NTFS.') }
        Mock Set-Content {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should run immediate scan, write filtered log and open Notepad' {
        Start-ChkDsk

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke New-Activity -Exactly 1
        Should -Invoke chkdsk -Exactly 1
        Should -Invoke chkdsk -Exactly 1 -ParameterFilter { $args -contains '/scan' -and $args -contains '/perf' }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter { $Path -eq $TestLogPath }
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'notepad.exe' -and
            $ArgumentList -eq $TestLogPath
        }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should filter out progress lines and update progress bar from total percentage' {
        Mock chkdsk {
            return @(
                'The type of the file system is NTFS.',
                'Progress: 0 of 2264064 done; Stage:  0%; Total:  0%; ETA:   1:48:50    ',
                'Progress: 500000 of 2264064 done; Stage: 22%; Total: 50%; ETA:   0:01:00    ',
                '2264064 file records processed.',
                'Progress: 2264064 of 2264064 done; Stage: 100%; Total: 99%; ETA:   0:00:01    ',
                'Windows has scanned the file system and found no problems.'
            )
        }

        Start-ChkDsk

        Should -Invoke Write-ActivityProgress -Exactly 3
        Should -Invoke Write-ActivityProgress -Exactly 1 -ParameterFilter { $PercentComplete -eq 0 }
        Should -Invoke Write-ActivityProgress -Exactly 1 -ParameterFilter { $PercentComplete -eq 50 }
        Should -Invoke Write-ActivityProgress -Exactly 1 -ParameterFilter { $PercentComplete -eq 99 }

        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Value -notmatch '\d+\s*%.*\d+\s*%' -and
            $Value -match 'The type of the file system is NTFS\.' -and
            $Value -match '2264064 file records processed\.'
        }
    }

    It 'Should handle non-English chkdsk progress output' {
        Mock chkdsk {
            return @(
                'Тип файловой системы: NTFS.',
                'Выполнено: 0 из 2264064; Этап:  0%; Всего:  0%; Осталось:   1:48:50    ',
                'Выполнено: 500000 из 2264064; Этап: 22%; Всего: 50%; Осталось:   0:01:00    ',
                '2264064 записей файлов обработано.',
                'Windows проверила файловую систему и не нашла проблем.'
            )
        }

        Start-ChkDsk

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Write-ActivityProgress -Exactly 1 -ParameterFilter { $PercentComplete -eq 0 }
        Should -Invoke Write-ActivityProgress -Exactly 1 -ParameterFilter { $PercentComplete -eq 50 }
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Value -notmatch '\d+\s*%.*\d+\s*%' -and
            $Value -match 'Тип файловой системы: NTFS\.' -and
            $Value -match '2264064 записей файлов обработано\.' -and
            $Value -match 'Windows проверила файловую систему'
        }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should schedule full scan via cmd when ScheduleFullScan is specified' {
        Start-ChkDsk -ScheduleFullScan

        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke New-Activity -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'cmd' -and
            $ArgumentList -eq '/c "echo y | chkdsk /f /r"' -and
            $NoNewWindow -eq $True -and
            $Wait -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle chkdsk failure during immediate scan' {
        Mock chkdsk { throw $TestException }

        Start-ChkDsk

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Start-Process failure when scheduling full scan' {
        Mock Start-Process { throw $TestException }

        Start-ChkDsk -ScheduleFullScan

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
