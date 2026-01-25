BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestCommand ([String]'TEST_COMMAND')
}

Describe 'Invoke-CustomCommand' {
    BeforeEach {
        Mock Start-Process {}
    }

    It 'Should invoke Start-Process with normal privileges and window' {
        Invoke-CustomCommand $TestCommand

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'PowerShell' -and
            $ArgumentList -eq $TestCommand -and
            $Verb -eq 'Open' -and
            $WindowStyle -eq 'Normal'
        }
    }

    It 'Should invoke Start-Process with elevated privileges and window' {
        Invoke-CustomCommand $TestCommand -Elevated

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'PowerShell' -and
            $ArgumentList -eq $TestCommand -and
            $Verb -eq 'RunAs' -and
            $WindowStyle -eq 'Normal'
        }
    }

    It 'Should invoke Start-Process with normal privileges and hidden window' {
        Invoke-CustomCommand $TestCommand -HideWindow

        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'PowerShell' -and
            $ArgumentList -eq $TestCommand -and
            $Verb -eq 'Open' -and
            $WindowStyle -eq 'Hidden'
        }
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Invoke-CustomCommand $TestCommand } | Should -Throw $TestException

        Should -Invoke Start-Process -Exactly 1
    }
}
