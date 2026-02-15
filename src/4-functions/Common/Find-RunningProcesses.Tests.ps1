BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestProcessName ([String]'TEST_PROCESS_NAME')
    Set-Variable -Option Constant TestProcessName2 ([String]'TEST_PROCESS_NAME_2')
    Set-Variable -Option Constant TestProcessName3 ([String]'TEST_PROCESS_NAME_3')
}

Describe 'Find-RunningProcesses' {
    BeforeEach {
        Mock Get-Process { return @(@{ ProcessName = $TestProcessName }) }
    }

    It 'Should find running process' {
        Set-Variable -Option Constant Result ([Hashtable](Find-RunningProcesses $TestProcessName))

        $Result.ProcessName | Should -BeExactly $TestProcessName

        Should -Invoke Get-Process -Exactly 1
    }

    It 'Should find running process from multiple names' {
        Set-Variable -Option Constant Result ([Hashtable](Find-RunningProcesses @($TestProcessName, $TestProcessName2)))

        $Result.ProcessName | Should -BeExactly $TestProcessName

        Should -Invoke Get-Process -Exactly 1
    }

    It 'Should find multiple running processes from multiple names' {
        Mock Get-Process { return @(@{ ProcessName = $TestProcessName }, @{ ProcessName = $TestProcessName2 }) }

        Set-Variable -Option Constant Result ([Array](Find-RunningProcesses @($TestProcessName, $TestProcessName2, $TestProcessName3)))

        $Result.Count | Should -Be 2
        $Result[0].ProcessName | Should -BeExactly $TestProcessName
        $Result[1].ProcessName | Should -BeExactly $TestProcessName2

        Should -Invoke Get-Process -Exactly 1
    }

    It 'Should not find non-running process' {
        Mock Get-Process { return @() }

        Find-RunningProcesses $TestProcessName | Should -BeNullOrEmpty

        Should -Invoke Get-Process -Exactly 1
    }

    It 'Should not find any from multiple non-running processes' {
        Mock Get-Process { return $null }

        Find-RunningProcesses @($TestProcessName, $TestProcessName2) | Should -BeNullOrEmpty

        Should -Invoke Get-Process -Exactly 1
    }

    It 'Should handle Get-Process failure' {
        Mock Get-Process { throw $TestException }

        { Find-RunningProcesses $TestProcessName } | Should -Throw $TestException

        Should -Invoke Get-Process -Exactly 1
    }
}
