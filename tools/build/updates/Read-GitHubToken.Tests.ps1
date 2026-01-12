BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestEnvPath ([String]'TEST_ENV_PATH')
}

Describe 'Read-GitHubToken' {
    BeforeEach {
        Mock Write-LogInfo {}
    }

    It 'Should read GitHub token from env file with no quotes' {
        Mock Get-Content {
            return 'GITHUB_TOKEN=TEST_GITHUB_TOKEN_CONTENT '
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestEnvPath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
    }

    It 'Should read GitHub token from env file with single quotes' {
        Mock Get-Content {
            return "GITHUB_TOKEN= 'TEST_GITHUB_TOKEN_CONTENT' "
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should read GitHub token from env file with double quotes' {
        Mock Get-Content {
            return 'GITHUB_TOKEN= "TEST_GITHUB_TOKEN_CONTENT" '
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should handle missing GitHub token in env file' {
        Mock Get-Content {
            return 'NOT_A_GITHUB_TOKEN=SOME_CONTENT'
        }

        Read-GitHubToken $TestEnvPath | Should -BeNullOrEmpty

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should read GitHub token from env file at beginning' {
        Mock Get-Content {
            return "GITHUB_TOKEN=TEST_GITHUB_TOKEN_CONTENT`nNOT_A_GITHUB_TOKEN=SOME_CONTENT"
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should read GitHub token from env file not at beginning' {
        Mock Get-Content {
            return "NOT_A_GITHUB_TOKEN=SOME_CONTENT`nGITHUB_TOKEN=TEST_GITHUB_TOKEN_CONTENT"
        }

        Read-GitHubToken $TestEnvPath | Should -BeExactly 'TEST_GITHUB_TOKEN_CONTENT'

        Should -Invoke Get-Content -Exactly 1
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { Read-GitHubToken $TestEnvPath } | Should -Throw

        Should -Invoke Get-Content -Exactly 1
    }
}
