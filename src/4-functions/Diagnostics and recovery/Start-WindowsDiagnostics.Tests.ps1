BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'
    . '.\src\4-functions\App lifecycle\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TestDrive:\AppDir')

    Set-Variable -Option Constant TestLogPath ([String]"$PATH_APP_DIR\windows_diagnostics.log")

    Set-Variable -Option Constant TestCbsLogPath ([String]"$env:SystemRoot\Logs\CBS\CBS.log")
}

Describe 'Start-WindowsDiagnostics' {
    BeforeEach {
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock Write-ActivityCompleted {}
        Mock Initialize-AppDirectory {}
        Mock Out-Success {}
        Mock Out-Failure {}
        Mock Write-LogInfo {}
        Mock Start-Process {}
        Mock Set-Content {}
        Mock Test-Path { return $False }
        Mock Get-Content {}

        Mock DISM { return @('The operation completed successfully.') }
        Mock sfc { return @('Windows Resource Protection did not find any integrity violations.') }
    }

    It 'Should run all diagnostics and open log' {
        Start-WindowsDiagnostics

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke DISM -Exactly 3
        Should -Invoke sfc -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'notepad.exe' -and
            $ArgumentList -eq $TestLogPath
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle DISM CheckHealth failure' {
        Mock DISM { throw $TestException } -ParameterFilter { $args -contains '/CheckHealth' }

        Start-WindowsDiagnostics

        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle DISM ScanHealth failure' {
        Mock DISM { throw $TestException } -ParameterFilter { $args -contains '/ScanHealth' }

        Start-WindowsDiagnostics

        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle DISM RestoreHealth failure' {
        Mock DISM { throw $TestException } -ParameterFilter { $args -contains '/RestoreHealth' }

        Start-WindowsDiagnostics

        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle SFC failure' {
        Mock sfc { throw $TestException }

        Start-WindowsDiagnostics

        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should extract SR entries from CBS.log' {
        Mock Test-Path { return $True }
        Mock Get-Content {
            return @(
                'Some unrelated log line',
                '[SR] Beginning Verify and Repair transaction',
                '[SR] Cannot repair member file',
                'Another unrelated line',
                '[SR] Verify complete'
            )
        }

        Start-WindowsDiagnostics

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should report no SFC entries when CBS.log has none' {
        Mock Test-Path { return $True }
        Mock Get-Content {
            return @(
                'Some unrelated log line',
                'Another unrelated line'
            )
        }

        Start-WindowsDiagnostics

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle CBS.log read failure' {
        Mock Test-Path { return $True }
        Mock Get-Content { throw $TestException }

        Start-WindowsDiagnostics

        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }
}
