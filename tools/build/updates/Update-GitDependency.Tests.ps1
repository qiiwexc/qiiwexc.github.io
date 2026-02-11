BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\types.ps1'

    . "$(Split-Path $PSCommandPath -Parent)\Compare-Tags.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Select-Releases.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Compare-Commits.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')
    Set-Variable -Option Constant TestDependency (
        [PSObject]@{
            name = 'TestDependency'
            mode = ''
        }
    )

    Set-Variable -Option Constant TestCompareTagsResult @('TEST_COMPARE_TAGS_RESULT')
    Set-Variable -Option Constant TestSelectReleasesResult @('TEST_SELECT_RELEASES_RESULT')
    Set-Variable -Option Constant TestCompareCommitsResult @('TEST_COMPARE_COMMITS_RESULT')
}

Describe 'Update-GitDependency' {
    BeforeEach {
        Mock Compare-Tags {
            return $TestCompareTagsResult
        }
        Mock Select-Releases {
            return $TestSelectReleasesResult
        }
        Mock Compare-Commits {
            return $TestCompareCommitsResult
        }
        Mock Write-LogWarning {}
    }

    Context 'tags' {
        BeforeEach {
            $TestDependency.mode = 'tags'
        }

        It 'Should update dependency with no token' {
            Update-GitDependency $TestDependency | Should -BeExactly $TestCompareTagsResult

            Should -Invoke Compare-Tags -Exactly 1
            Should -Invoke Compare-Tags -Exactly 1 -ParameterFilter {
                $Dependency.name -eq $TestDependency.name -and
                $Dependency.mode -eq $TestDependency.mode
            }
            Should -Invoke Select-Releases -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should update dependency with a token' {
            Update-GitDependency $TestDependency $TestGitHubToken | Should -BeExactly $TestCompareTagsResult

            Should -Invoke Compare-Tags -Exactly 1
            Should -Invoke Compare-Tags -Exactly 1 -ParameterFilter {
                $Dependency.name -eq $TestDependency.name -and
                $Dependency.mode -eq $TestDependency.mode
                $GitHubToken -eq $TestGitHubToken
            }
            Should -Invoke Select-Releases -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should handle Compare-Tags failure' {
            Mock Compare-Tags { throw $TestException }

            { Update-GitDependency $TestDependency } | Should -Throw $TestException

            Should -Invoke Compare-Tags -Exactly 1
            Should -Invoke Select-Releases -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }
    }

    Context 'releases' {
        BeforeEach {
            $TestDependency.mode = 'releases'
        }

        It 'Should update dependency with no token' {
            Update-GitDependency $TestDependency | Should -BeExactly $TestSelectReleasesResult

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Releases -Exactly 1
            Should -Invoke Select-Releases -Exactly 1 -ParameterFilter {
                $Dependency.name -eq $TestDependency.name -and
                $Dependency.mode -eq $TestDependency.mode
            }
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should update dependency with a token' {
            Update-GitDependency $TestDependency $TestGitHubToken | Should -BeExactly $TestSelectReleasesResult

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Releases -Exactly 1
            Should -Invoke Select-Releases -Exactly 1 -ParameterFilter {
                $Dependency.name -eq $TestDependency.name -and
                $Dependency.mode -eq $TestDependency.mode
                $GitHubToken -eq $TestGitHubToken
            }
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should handle Select-Releases failure' {
            Mock Select-Releases { throw $TestException }

            { Update-GitDependency $TestDependency } | Should -Throw $TestException

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Releases -Exactly 1
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }
    }

    Context 'commits' {
        BeforeEach {
            $TestDependency.mode = 'commits'
        }

        It 'Should update dependency with no token' {
            Update-GitDependency $TestDependency | Should -BeExactly $TestCompareCommitsResult

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Releases -Exactly 0
            Should -Invoke Compare-Commits -Exactly 1
            Should -Invoke Compare-Commits -Exactly 1 -ParameterFilter {
                $Dependency.name -eq $TestDependency.name -and
                $Dependency.mode -eq $TestDependency.mode
            }
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should update dependency with a token' {
            Update-GitDependency $TestDependency $TestGitHubToken | Should -BeExactly $TestCompareCommitsResult

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Releases -Exactly 0
            Should -Invoke Compare-Commits -Exactly 1
            Should -Invoke Compare-Commits -Exactly 1 -ParameterFilter {
                $Dependency.name -eq $TestDependency.name -and
                $Dependency.mode -eq $TestDependency.mode
                $GitHubToken -eq $TestGitHubToken
            }
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should handle Compare-Commits failure' {
            Mock Compare-Commits { throw $TestException }

            { Update-GitDependency $TestDependency } | Should -Throw $TestException

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Releases -Exactly 0
            Should -Invoke Compare-Commits -Exactly 1
            Should -Invoke Write-LogWarning -Exactly 0
        }
    }

    Context 'unknown' {
        BeforeEach {
            $TestDependency.mode = 'unknown'
        }

        It 'Should handle unknown mode' {
            Update-GitDependency $TestDependency

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Releases -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }
    }
}
