BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\types.ps1'

    . "$(Split-Path $PSCommandPath -Parent)\Invoke-GitAPI.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Set-NewVersion.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')

    Set-Variable -Option Constant TestRepositoryName ([String]'TEST_REPOSITORY_NAME')
    Set-Variable -Option Constant TestProjectId ([String]'TEST_PROJECT_ID')
    Set-Variable -Option Constant TestCurrentVersion ([String]'TEST_CURRENT_VERSION')
    Set-Variable -Option Constant TestLatestVersion ([String]'TEST_LATEST_VERSION')

    Set-Variable -Option Constant TestGitHubTagsUrl ([String]"https://api.github.com/repos/$TestRepositoryName/tags")
    Set-Variable -Option Constant TestDependency (
        [PSObject]@{
            projectId  = $TestProjectId
            repository = $TestRepositoryName
            source     = ''
            version    = $TestCurrentVersion
        }
    )

    Set-Variable -Option Constant TestGitHubCompareTagsResult @("https://github.com/$TestRepositoryName/compare/$TestCurrentVersion...$TestLatestVersion")
}

Describe 'Compare-Tags' {
    BeforeEach {
        Mock Invoke-GitAPI { return @( @{ Name = $TestLatestVersion }, @{ Name = $TestCurrentVersion } ) }
        Mock Set-NewVersion {}

        $TestDependency.source = 'GitHub'
    }

    It 'Should update to new version from GitLab' {
        $TestDependency.source = 'GitLab'

        Compare-Tags $TestDependency | Should -BeExactly @("https://gitlab.com/$TestRepositoryName/compare/$TestCurrentVersion...$TestLatestVersion")

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq "https://gitlab.com/api/v4/projects/$TestProjectId/repository/tags" }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency.projectId -eq $TestProjectId -and
            $Dependency.repository -eq $TestRepositoryName -and
            $Dependency.source -eq 'GitLab' -and
            $Dependency.version -eq $TestCurrentVersion -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should update to new version from GitHub without GitHub token' {
        Compare-Tags $TestDependency | Should -BeExactly $TestGitHubCompareTagsResult

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq $TestGitHubTagsUrl }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency.repository -eq $TestRepositoryName -and
            $Dependency.source -eq 'GitHub' -and
            $Dependency.version -eq $TestCurrentVersion -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should update to new version from GitHub with GitHub token' {
        Compare-Tags $TestDependency $TestGitHubToken | Should -BeExactly $TestGitHubCompareTagsResult

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter {
            $Uri -eq $TestGitHubTagsUrl -and
            $GitHubToken -eq $TestGitHubToken
        }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency.repository -eq $TestRepositoryName -and
            $Dependency.source -eq 'GitHub' -and
            $Dependency.version -eq $TestCurrentVersion -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should not update if version is the same' {
        Mock Invoke-GitAPI { return @( @{ Name = $TestCurrentVersion }, @{ Name = $TestCurrentVersion } ) }

        Compare-Tags $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if new version is empty' {
        Mock Invoke-GitAPI { return @( @{}, @{} ) }

        Compare-Tags $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if the response is empty' {
        Mock Invoke-GitAPI { return @() }

        Compare-Tags $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should handle Invoke-GitAPI failure' {
        Mock Invoke-GitAPI { throw $TestException }

        { Compare-Tags $TestDependency } | Should -Throw $TestException

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
