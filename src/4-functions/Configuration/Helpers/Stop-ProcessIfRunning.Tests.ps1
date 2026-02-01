BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\Common\Find-RunningProcess.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestProcessName ([String]'TEST_PROCESS_NAME')
}

Describe 'Stop-ProcessIfRunning' {
    BeforeEach {
        Mock Find-RunningProcess { return @(@{ ProcessName = $TestProcessName }) }
        Mock Write-LogInfo {}
        Mock Stop-Process {}
        Mock Out-Success {}
    }

    It 'Should stop running process' {
        Stop-ProcessIfRunning $TestProcessName

        Should -Invoke Find-RunningProcess -Exactly 1
        Should -Invoke Find-RunningProcess -Exactly 1 -ParameterFilter { $ProcessName -eq $TestProcessName }
        Should -Invoke Stop-Process -Exactly 1
        Should -Invoke Stop-Process -Exactly 1 -ParameterFilter {
            $Name -eq $TestProcessName -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip if process is not running' {
        Mock Find-RunningProcess { return @() }

        Stop-ProcessIfRunning $TestProcessName

        Should -Invoke Find-RunningProcess -Exactly 1
        Should -Invoke Stop-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Find-RunningProcess failure' {
        Mock Find-RunningProcess { throw $TestException }

        { Stop-ProcessIfRunning $TestProcessName } | Should -Throw $TestException

        Should -Invoke Find-RunningProcess -Exactly 1
        Should -Invoke Stop-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Stop-Process failure' {
        Mock Stop-Process { throw $TestException }

        { Stop-ProcessIfRunning $TestProcessName } | Should -Throw $TestException

        Should -Invoke Find-RunningProcess -Exactly 1
        Should -Invoke Stop-Process -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
