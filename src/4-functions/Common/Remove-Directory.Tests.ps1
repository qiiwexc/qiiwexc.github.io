BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestDirectoryPath ([String]'TEST_DIRECTORY_PATH')
}

Describe 'Remove-Directory' {
    BeforeEach {
        Mock Test-Path { return $True }
        Mock Remove-Item {}
    }

    It 'Should remove existing directory' {
        Remove-Directory $TestDirectoryPath

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestDirectoryPath }
        Should -Invoke Remove-Item -Exactly 1
        Should -Invoke Remove-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestDirectoryPath -and
            $Recurse -eq $True -and
            $Force -eq $True
        }
    }

    It 'Should remove existing directory silently' {
        Remove-Directory $TestDirectoryPath -Silent

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 1
    }

    It 'Should skip missing directory' {
        Mock Test-Path { return $False }

        Remove-Directory $TestDirectoryPath

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        { Remove-Directory $TestDirectoryPath } | Should -Throw $TestException

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 0
    }

    It 'Should handle Remove-Item failure' {
        Mock Remove-Item { throw $TestException }

        { Remove-Directory $TestDirectoryPath } | Should -Throw $TestException

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 1
    }
}
