BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\types.ps1'

    . "$(Split-Path $PSCommandPath -Parent)\Compare-Tags.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Select-Tags.ps1"
    . "$(Split-Path $PSCommandPath -Parent)\Compare-Commits.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')
    Set-Variable -Option Constant TestDependency (
        [PSCustomObject]@{
            name = 'TestDependency'
            mode = ''
        }
    )

    Set-Variable -Option Constant TestCompareTagsResult @('TEST_COMPARE_TAGS_RESULT')
    Set-Variable -Option Constant TestSelectTagsResult @('TEST_SELECT_TAGS_RESULT')
    Set-Variable -Option Constant TestCompareCommitsResult @('TEST_COMPARE_COMMITS_RESULT')
}

Describe 'Update-GitDependency' {
    BeforeEach {
        Mock Compare-Tags {
            return $TestCompareTagsResult
        }
        Mock Select-Tags {
            return $TestSelectTagsResult
        }
        Mock Compare-Commits {
            return $TestCompareCommitsResult
        }
        Mock Write-LogWarning {}
    }

    Context 'compare' {
        BeforeEach {
            $TestDependency.mode = 'compare'
        }

        It 'Should update dependency with no token' {
            Update-GitDependency $TestDependency | Should -BeExactly $TestCompareTagsResult

            Should -Invoke Compare-Tags -Exactly 1
            Should -Invoke Compare-Tags -Exactly 1 -ParameterFilter { $Dependency -eq $TestDependency }
            Should -Invoke Select-Tags -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should update dependency with a token' {
            Update-GitDependency $TestDependency $TestGitHubToken | Should -BeExactly $TestCompareTagsResult

            Should -Invoke Compare-Tags -Exactly 1
            Should -Invoke Compare-Tags -Exactly 1 -ParameterFilter {
                $Dependency -eq $TestDependency -and
                $GitHubToken -eq $TestGitHubToken
            }
            Should -Invoke Select-Tags -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should handle Compare-Tags failure' {
            Mock Compare-Tags { throw $TestException }

            { Update-GitDependency $TestDependency } | Should -Throw $TestException

            Should -Invoke Compare-Tags -Exactly 1
            Should -Invoke Select-Tags -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }
    }

    Context 'tags' {
        BeforeEach {
            $TestDependency.mode = 'tags'
        }

        It 'Should update dependency with no token' {
            Update-GitDependency $TestDependency | Should -BeExactly $TestSelectTagsResult

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Tags -Exactly 1
            Should -Invoke Select-Tags -Exactly 1 -ParameterFilter { $Dependency -eq $TestDependency }
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should update dependency with a token' {
            Update-GitDependency $TestDependency $TestGitHubToken | Should -BeExactly $TestSelectTagsResult

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Tags -Exactly 1
            Should -Invoke Select-Tags -Exactly 1 -ParameterFilter {
                $Dependency -eq $TestDependency -and
                $GitHubToken -eq $TestGitHubToken
            }
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should handle Select-Tags failure' {
            Mock Select-Tags { throw $TestException }

            { Update-GitDependency $TestDependency } | Should -Throw $TestException

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Tags -Exactly 1
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
            Should -Invoke Select-Tags -Exactly 0
            Should -Invoke Compare-Commits -Exactly 1
            Should -Invoke Compare-Commits -Exactly 1 -ParameterFilter { $Dependency -eq $TestDependency }
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should update dependency with a token' {
            Update-GitDependency $TestDependency $TestGitHubToken | Should -BeExactly $TestCompareCommitsResult

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Tags -Exactly 0
            Should -Invoke Compare-Commits -Exactly 1
            Should -Invoke Compare-Commits -Exactly 1 -ParameterFilter {
                $Dependency -eq $TestDependency -and
                $GitHubToken -eq $TestGitHubToken
            }
            Should -Invoke Write-LogWarning -Exactly 0
        }

        It 'Should handle Compare-Commits failure' {
            Mock Compare-Commits { throw $TestException }

            { Update-GitDependency $TestDependency } | Should -Throw $TestException

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Tags -Exactly 0
            Should -Invoke Compare-Commits -Exactly 1
            Should -Invoke Write-LogWarning -Exactly 0
        }
    }

    Context 'unknown' {
        BeforeEach {
            $TestDependency.mode = 'unknown'
        }

        It 'Should handle unknown mode' {
            { Update-GitDependency $TestDependency } | Should -Throw

            Should -Invoke Compare-Tags -Exactly 0
            Should -Invoke Select-Tags -Exactly 0
            Should -Invoke Compare-Commits -Exactly 0
            Should -Invoke Write-LogWarning -Exactly 0
        }
    }
}
