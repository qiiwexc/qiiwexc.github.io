BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestCommandLinePart ([String]'TEST_COMMAND_LINE_PART')

    Set-Variable -Option Constant TestCommandLine ([String]"powershell.exe -File $TestCommandLinePart.ps1")
    Set-Variable -Option Constant TestCimInstance ([PSCustomObject]@{ CommandLine = $TestCommandLine })
}

Describe 'Find-RunningScript' {
    BeforeEach {
        Mock Get-CimInstance { return @($TestCimInstance) }
    }

    It 'Should find running script' {
        Set-Variable -Option Constant Result ([PSCustomObject](Find-RunningScript $TestCommandLinePart))

        $Result.CommandLine | Should -BeExactly $TestCommandLine

        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter {
            $ClassName -eq 'Win32_Process' -and
            $Filter -eq "name='powershell.exe'"
        }
    }

    It 'Should not find non-running script' {
        Mock Get-CimInstance { return @() }

        Find-RunningScript $TestCommandLinePart | Should -BeNullOrEmpty

        Should -Invoke Get-CimInstance -Exactly 1
    }

    It 'Should handle Get-CimInstance failure' {
        Mock Get-CimInstance { throw $TestException }

        { Find-RunningScript $TestCommandLinePart } | Should -Throw $TestException

        Should -Invoke Get-CimInstance -Exactly 1
    }
}
