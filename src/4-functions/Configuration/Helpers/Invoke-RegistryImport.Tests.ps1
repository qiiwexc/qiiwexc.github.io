BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Invoke-RegCommand.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestPath ([String]'TEST_PATH\TEST_APP_NAME.reg')

    [Bool]$OS_64_BIT = $True
}

Describe 'Invoke-RegistryImport' {
    BeforeAll {
        Mock Invoke-RegCommand { return 0 }
    }

    It 'Should import into the 64-bit view on a 64-bit system' {
        Invoke-RegistryImport $TestPath | Should -BeExactly 0

        Should -Invoke Invoke-RegCommand -Exactly 1
        Should -Invoke Invoke-RegCommand -Exactly 1 -ParameterFilter { ($Arguments -join ' ') -eq "import `"$TestPath`" /reg:64" }
    }

    It 'Should use the default registry view on a 32-bit system' {
        [Bool]$OS_64_BIT = $False

        Invoke-RegistryImport $TestPath | Should -BeExactly 0

        Should -Invoke Invoke-RegCommand -Exactly 1 -ParameterFilter { ($Arguments -join ' ') -eq "import `"$TestPath`"" }
    }

    It 'Should return the exit code of a failed import' {
        Mock Invoke-RegCommand { return 1 }

        Invoke-RegistryImport $TestPath | Should -BeExactly 1
    }

    It 'Should handle Invoke-RegCommand failure' {
        Mock Invoke-RegCommand { throw $TestException }

        { Invoke-RegistryImport $TestPath } | Should -Throw $TestException
    }
}
