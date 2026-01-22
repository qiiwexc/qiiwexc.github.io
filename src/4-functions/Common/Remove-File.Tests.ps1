BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestFilePath ([String]'TEST_FILE_PATH')
}

Describe 'Remove-File' {
    BeforeEach {
        Mock Test-Path { return $True }
        Mock Remove-Item {}
    }

    It 'Should remove existing file' {
        Remove-File $TestFilePath

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestFilePath }
        Should -Invoke Remove-Item -Exactly 1
        Should -Invoke Remove-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestFilePath -and
            $Force -eq $True
        }
    }

    It 'Should remove existing file silently' {
        Remove-File $TestFilePath -Silent

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 1
    }

    It 'Should skip missing file' {
        Mock Test-Path { return $False }

        Remove-File $TestFilePath

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        { Remove-File $TestFilePath } | Should -Throw $TestException

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 0
    }

    It 'Should handle Remove-Item failure' {
        Mock Remove-Item { throw $TestException }

        { Remove-File $TestFilePath } | Should -Throw $TestException

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Remove-Item -Exactly 1
    }
}
