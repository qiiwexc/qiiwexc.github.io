BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestRegistryKey ([String]'HKCU:\Software\Unchecky')
    Set-Variable -Option Constant TestUncheckyUrl ([String]'{URL_UNCHECKY}')
}

Describe 'Update-Windows' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Out-Failure {}

        [Int]$OS_VERSION = 11
    }

    It 'Should update Windows' {
        Update-Windows

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'UsoClient' -and
            $ArgumentList -eq 'StartInteractiveScan'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should update Windows successfully on Windows 7' {
        $OS_VERSION = 7

        Update-Windows

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'wuauclt' -and
            $ArgumentList -eq '/detectnow /updatenow'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Update-Windows

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
