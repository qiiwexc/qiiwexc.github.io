BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$(Split-Path $PSCommandPath -Parent)\Invoke-GitAPI.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')
    Set-Variable -Option Constant TestRepository ([String]'owner/project')
    Set-Variable -Option Constant TestTag ([String]'v1.2.3')
    Set-Variable -Option Constant TestNotes ([String]'TEST_NOTES')
}

Describe 'Get-ReleaseNotes' {
    BeforeAll {
        Mock Invoke-GitAPI { return @([PSCustomObject]@{ tag_name = $TestTag; body = $TestNotes }) }
    }

    It 'Should return the notes of the release' {
        Get-ReleaseNotes $TestRepository $TestTag $TestGitHubToken | Should -BeExactly $TestNotes

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter {
            $Uri -eq "https://api.github.com/repos/$TestRepository/releases/tags/$TestTag" -and
            $GitHubToken -eq $TestGitHubToken
        }
    }

    It 'Should escape the tag in the API URL' {
        Get-ReleaseNotes $TestRepository 'release 1/2'

        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq "https://api.github.com/repos/$TestRepository/releases/tags/release%201%2F2" }
    }

    It 'Should return an empty string for a release without notes: <Case>' -ForEach @(
        @{ Case = 'empty'; Release = [PSCustomObject]@{ tag_name = 'v1'; body = '' } }
        @{ Case = 'null'; Release = [PSCustomObject]@{ tag_name = 'v1'; body = $Null } }
        @{ Case = 'missing'; Release = [PSCustomObject]@{ tag_name = 'v1' } }
    ) {
        Mock Invoke-GitAPI { return @($Release) }

        Get-ReleaseNotes $TestRepository $TestTag | Should -BeExactly ''
    }

    It 'Should return null when there is no release for the tag' {
        Mock Invoke-GitAPI { throw $TestException }

        Get-ReleaseNotes $TestRepository $TestTag | Should -BeNullOrEmpty
        $Null -eq (Get-ReleaseNotes $TestRepository $TestTag) | Should -BeTrue
    }
}
