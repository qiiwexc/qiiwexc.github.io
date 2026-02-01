BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestProcessName ([String]'TEST_PROCESS_NAME')
}

Describe 'Find-RunningProcess' {
    BeforeEach {
        Mock Get-Process { return @(@{ ProcessName = $TestProcessName }) }
    }

    It 'Should find running process' {
        Set-Variable -Option Constant Result ([Hashtable](Find-RunningProcess $TestProcessName))

        $Result.ProcessName | Should -BeExactly $TestProcessName

        Should -Invoke Get-Process -Exactly 1
    }

    It 'Should skip if process is not running' {
        Mock Get-Process { return @() }

        Find-RunningProcess $TestProcessName | Should -BeNullOrEmpty

        Should -Invoke Get-Process -Exactly 1
    }

    It 'Should handle Get-Process failure' {
        Mock Get-Process { throw $TestException }

        { Find-RunningProcess $TestProcessName } | Should -Throw $TestException

        Should -Invoke Get-Process -Exactly 1
    }
}
