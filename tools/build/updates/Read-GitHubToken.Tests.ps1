BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\Read-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestEnvPath ([String]'TEST_ENV_PATH')
}

Describe 'Read-GitHubToken' {
    BeforeEach {
        Mock Write-LogInfo {}
    }

    It 'Should read GitHub token from env file with no quotes' {
        Mock Read-TextFile {
            return @('GITHUB_TOKEN=TEST_GITHUB_TOKEN_CONTENT ')
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestEnvPath -and
            $AsList -eq $True
        }
    }

    It 'Should read GitHub token from env file with single quotes' {
        Mock Read-TextFile {
            return @("GITHUB_TOKEN= 'TEST_GITHUB_TOKEN_CONTENT' ")
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should read GitHub token from env file with double quotes' {
        Mock Read-TextFile {
            return @('GITHUB_TOKEN= "TEST_GITHUB_TOKEN_CONTENT" ')
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should handle missing GitHub token in env file' {
        Mock Read-TextFile {
            return @('NOT_A_GITHUB_TOKEN=SOME_CONTENT')
        }

        Read-GitHubToken $TestEnvPath | Should -BeNullOrEmpty

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should read GitHub token from env file at beginning' {
        Mock Read-TextFile {
            return @('GITHUB_TOKEN=TEST_GITHUB_TOKEN_CONTENT', 'NOT_A_GITHUB_TOKEN=SOME_CONTENT')
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should read GitHub token from env file not at beginning' {
        Mock Read-TextFile {
            return @('NOT_A_GITHUB_TOKEN=SOME_CONTENT', 'GITHUB_TOKEN=TEST_GITHUB_TOKEN_CONTENT')
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Read-TextFile -Exactly 1
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { Read-GitHubToken $TestEnvPath } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 1
    }
}
