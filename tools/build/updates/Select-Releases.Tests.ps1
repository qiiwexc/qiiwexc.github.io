BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\types.ps1'

    . "$(Split-Path $PSCommandPath -Parent)\Invoke-GitAPI.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Set-NewVersion.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')

    Set-Variable -Option Constant TestRepositoryName ([String]'TEST_REPOSITORY_NAME')

    Set-Variable -Option Constant TestCurrentVersion ([String]'v1.0.0')
    Set-Variable -Option Constant TestNewVersion ([String]'v2.0.0')
    Set-Variable -Option Constant TestLatestVersion ([String]'v3.0.0')

    Set-Variable -Option Constant TestGitHubReleasesUrl ([String]"https://api.github.com/repos/$TestRepositoryName/releases?per_page=5")

    Set-Variable -Option Constant TestNewVersionUrl ([String]"https://github.com/$TestRepositoryName/releases/$TestNewVersion")
    Set-Variable -Option Constant TestLatestVersionUrl ([String]"https://github.com/$TestRepositoryName/releases/$TestLatestVersion")

    Set-Variable -Option Constant TestDependency (
        [PSObject]@{
            repository = $TestRepositoryName
            version    = $TestCurrentVersion
        }
    )
}

Describe 'Select-Releases' {
    BeforeEach {
        Mock Invoke-GitAPI { return @( @{ tag_name = $TestNewVersion }, @{ tag_name = $TestCurrentVersion } ) }
        Mock Set-NewVersion {}
    }

    It 'Should update to new version from GitHub without GitHub token' {
        Select-Releases $TestDependency | Should -BeExactly @($TestNewVersionUrl)

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter { $Uri -eq $TestGitHubReleasesUrl }
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency.repository -eq $TestRepositoryName -and
            $Dependency.version -eq $TestCurrentVersion -and
            $LatestVersion -eq $TestNewVersion
        }
    }

    It 'Should update to new version from GitHub with GitHub token' {
        Select-Releases $TestDependency $TestGitHubToken | Should -BeExactly @($TestNewVersionUrl)

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Invoke-GitAPI -Exactly 1 -ParameterFilter {
            $Uri -eq $TestGitHubReleasesUrl -and
            $GitHubToken -eq $TestGitHubToken
        }
        Should -Invoke Set-NewVersion -Exactly 1
    }

    It 'Should update to latest version if multiple new versions are available' {
        Mock Invoke-GitAPI { return @( @{ tag_name = $TestLatestVersion }, @{ tag_name = $TestNewVersion }, @{ tag_name = $TestCurrentVersion } ) }

        Select-Releases $TestDependency | Should -BeExactly @($TestLatestVersionUrl, $TestNewVersionUrl)

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1 -ParameterFilter {
            $Dependency.repository -eq $TestRepositoryName -and
            $Dependency.version -eq $TestCurrentVersion -and
            $LatestVersion -eq $TestLatestVersion
        }
    }

    It 'Should skip beta versions' {
        Mock Invoke-GitAPI { return @( @{ tag_name = "$TestNewVersion-beta" }, @{ tag_name = $TestCurrentVersion } ) }

        Select-Releases $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if version is the same' {
        Mock Invoke-GitAPI { return @( @{ tag_name = $TestCurrentVersion }, @{ tag_name = $TestCurrentVersion } ) }

        Select-Releases $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if new version is empty' {
        Mock Invoke-GitAPI { return @( @{}, @{} ) }

        Select-Releases $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should not update if the response is empty' {
        Mock Invoke-GitAPI { return @() }

        Select-Releases $TestDependency | Should -BeNullOrEmpty

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }

    It 'Should skip non-parseable version tags' {
        Mock Invoke-GitAPI { return @( @{ tag_name = $TestNewVersion }, @{ tag_name = 'non-parseable-tag' }, @{ tag_name = $TestCurrentVersion } ) }

        Select-Releases $TestDependency | Should -BeExactly @($TestNewVersionUrl)

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 1
    }

    It 'Should handle Invoke-GitAPI failure' {
        Mock Invoke-GitAPI { throw $TestException }

        { Select-Releases $TestDependency } | Should -Throw $TestException

        Should -Invoke Invoke-GitAPI -Exactly 1
        Should -Invoke Set-NewVersion -Exactly 0
    }
}
