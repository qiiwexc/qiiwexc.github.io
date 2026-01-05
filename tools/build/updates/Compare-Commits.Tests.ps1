BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$(Split-Path $PSCommandPath -Parent)\Invoke-GitAPI.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Set-NewVersion.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')

    Set-Variable -Option Constant TestRepositoryName ([String]'TEST_REPOSITORY_NAME')
    Set-Variable -Option Constant TestCurrentVersion ([String]'TEST_CURRENT_VERSION')
    Set-Variable -Option Constant TestLatestVersion ([String]'TEST_LATEST_VERSION')

    Set-Variable -Option Constant TestCommitsUrl ([String]"https://api.github.com/repos/$TestRepositoryName/commits")
    Set-Variable -Option Constant TestDependency (
        [Object]@{
            repository = $TestRepositoryName
            version    = $TestCurrentVersion
        }
    )

    Set-Variable -Option Constant TestCompareCommitsResult @("https://github.com/$TestRepositoryName/compare/$TestCurrentVersion...$TestLatestVersion")
}

Describe 'Compare-Commits' {
    BeforeEach {
        Mock Invoke-GitAPI { return @( @{ sha = $TestLatestVersion }, @{ sha = $TestCurrentVersion } ) }
        Mock Set-NewVersion {}
    }

    It 'Should update to new version without GitHub token' {
        Compare-Commits $TestDependency | Should -BeExactly $TestCompareCommitsResult

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq $TestCommitsUrl }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should update to new version with GitHub token' {
        Compare-Commits $TestDependency $TestGitHubToken | Should -BeExactly $TestCompareCommitsResult

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter {
            $Uri -eq $TestCommitsUrl -and
            $GitHubToken -eq $TestGitHubToken
        }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should not update if version is the same' {
        Mock Invoke-GitAPI { return @( @{ sha = $TestCurrentVersion }, @{ sha = $TestCurrentVersion } ) }

        Compare-Commits $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq $TestCommitsUrl }
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if the response is empty' {
        Mock Invoke-GitAPI { return @() }

        Compare-Commits $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq $TestCommitsUrl }
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should handle Invoke-GitAPI failure' {
        Mock Invoke-GitAPI { throw $TestException }

        { Compare-Commits $TestDependency } | Should -Throw

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq $TestCommitsUrl }
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
