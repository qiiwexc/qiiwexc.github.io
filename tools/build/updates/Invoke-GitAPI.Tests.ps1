BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')
    Set-Variable -Option Constant TestUrl ([String]'TEST_URL')
}

Describe 'Invoke-GitAPI' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Out-Failure {}
        Mock Invoke-WebRequest { return @{Content = '{"key1": "value1", "key2": "value2"}' } }
    }

    It 'Should invoke GitHub API without GitHub token' {
        Set-Variable -Option Constant Result (Invoke-GitAPI $TestUrl)

        $Result.key1 | Should -BeExactly 'value1'
        $Result.key2 | Should -BeExactly 'value2'

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq $TestUrl -and
            $Method -eq 'Get' -and
            $UseBasicParsing -eq $True
        }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should invoke GitHub API with GitHub token' {
        Set-Variable -Option Constant Result (Invoke-GitAPI $TestUrl $TestGitHubToken)

        $Result.key1 | Should -BeExactly 'value1'
        $Result.key2 | Should -BeExactly 'value2'

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq $TestUrl -and
            $Method -eq 'Get' -and
            $UseBasicParsing -eq $True -and
            $Headers.Authorization -eq "token $TestGitHubToken"
        }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        Invoke-GitAPI $TestUrl | Should -BeNullOrEmpty

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
    }
}
