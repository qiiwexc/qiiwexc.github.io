BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$(Split-Path $PSCommandPath -Parent)\Invoke-GitAPI.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Set-NewVersion.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')

    Set-Variable -Option Constant TestRepositoryName ([String]'TEST_REPOSITORY_NAME')

    Set-Variable -Option Constant TestCurrentVersion ([String]'v1.0.0')
    Set-Variable -Option Constant TestNewVersion ([String]'v2.0.0')
    Set-Variable -Option Constant TestLatestVersion ([String]'v3.0.0')

    Set-Variable -Option Constant TestGitHubTagsUrl ([String]"https://api.github.com/repos/$TestRepositoryName/tags")

    Set-Variable -Option Constant TestNewVersionUrl ([String]"https://github.com/$TestRepositoryName/releases/tag/$TestNewVersion")
    Set-Variable -Option Constant TestLatestVersionUrl ([String]"https://github.com/$TestRepositoryName/releases/tag/$TestLatestVersion")

    Set-Variable -Option Constant TestDependency (
        [Object]@{
            repository = $TestRepositoryName
            version    = $TestCurrentVersion
        }
    )
}

Describe 'Select-Tags' {
    BeforeEach {
        Mock Invoke-GitAPI { return @( @{ Name = $TestNewVersion }, @{ Name = $TestCurrentVersion } ) }
        Mock Set-NewVersion {}
    }

    It 'Should update to new version from GitHub without GitHub token' {
        Select-Tags $TestDependency | Should -BeExactly @($TestNewVersionUrl)

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq $TestGitHubTagsUrl }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestNewVersion
        }
    }

    It 'Should update to new version from GitHub with GitHub token' {
        Select-Tags $TestDependency $TestGitHubToken | Should -BeExactly @($TestNewVersionUrl)

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter {
            $Uri -eq $TestGitHubTagsUrl -and
            $GitHubToken -eq $TestGitHubToken
        }
        Should -Invoke Set-NewVersion -Exactly 1
    }

    It 'Should update to latest version if multiple new versions are available' {
        Mock Invoke-GitAPI { return @( @{ Name = $TestLatestVersion }, @{ Name = $TestNewVersion }, @{ Name = $TestCurrentVersion } ) }

        Select-Tags $TestDependency | Should -BeExactly @($TestLatestVersionUrl, $TestNewVersionUrl)

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency -eq $TestDependency -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should not update if version is the same' {
        Mock Invoke-GitAPI { return @( @{ Name = $TestCurrentVersion }, @{ Name = $TestCurrentVersion } ) }

        Select-Tags $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if new version is empty' {
        Mock Invoke-GitAPI { return @( @{}, @{} ) }

        Select-Tags $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if the response is empty' {
        Mock Invoke-GitAPI { return @() }

        Select-Tags $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should handle Invoke-GitAPI failure' {
        Mock Invoke-GitAPI { throw $TestException }

        { Select-Tags $TestDependency } | Should -Throw $TestException

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
