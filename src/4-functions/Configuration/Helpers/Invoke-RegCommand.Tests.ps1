BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestArguments ([String[]]@('TEST_ARGUMENT_1', 'TEST_ARGUMENT_2'))

    # Stands in for the reg.exe process: counts the waits and disposals, and can refuse to be turned into a string,
    # like a process that has exited
    function New-TestProcess {
        param(
            [Int]$ExitCode = 0,
            [Switch]$Exited
        )

        Set-Variable -Option Constant Process ([PSCustomObject]@{ ExitCode = $ExitCode; Waits = 0; Disposals = 0 })
        $Process | Add-Member -MemberType ScriptMethod -Name WaitForExit -Value { $this.Waits++ }
        $Process | Add-Member -MemberType ScriptMethod -Name Dispose -Value { $this.Disposals++ }
        if ($Exited) {
            $Process | Add-Member -MemberType ScriptMethod -Name ToString -Value { throw 'Process has exited, so the requested information is not available.' } -Force
        }
        return $Process
    }
}

Describe 'Invoke-RegCommand' {
    BeforeEach {
        $script:Process = New-TestProcess
    }

    BeforeAll {
        Mock Start-Process { return $script:Process }
    }

    It 'Should run reg.exe hidden with the arguments given and wait for it' {
        Invoke-RegCommand $TestArguments | Should -BeExactly 0

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'reg' -and
            ($ArgumentList -join ' ') -eq ($TestArguments -join ' ') -and
            $WindowStyle -eq 'Hidden' -and
            $PassThru -eq $True -and
            -not $PesterBoundParameters.ContainsKey('Wait')
        }
        $script:Process.Waits | Should -BeExactly 1
        $script:Process.Disposals | Should -BeExactly 1
    }

    It 'Should return the exit code of a failed command' {
        $script:Process = New-TestProcess -ExitCode 1

        Invoke-RegCommand $TestArguments | Should -BeExactly 1

        $script:Process.Disposals | Should -BeExactly 1
    }

    It 'Should read the exit code of a process that has exited' {
        $script:Process = New-TestProcess -Exited

        Invoke-RegCommand $TestArguments | Should -BeExactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Invoke-RegCommand $TestArguments } | Should -Throw $TestException
    }
}
