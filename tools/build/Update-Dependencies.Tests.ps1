BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\common\logger.ps1"
    . "$PSScriptRoot\..\common\types.ps1"
    . "$PSScriptRoot\..\common\Progressbar.ps1"
    . "$PSScriptRoot\..\common\Read-JsonFile.ps1"
    . "$PSScriptRoot\..\common\Write-JsonFile.ps1"
    . "$PSScriptRoot\updates\Read-GitHubToken.ps1"
    . "$PSScriptRoot\updates\Update-DependencyChecksum.ps1"
    . "$PSScriptRoot\updates\Update-FileDependency.ps1"
    . "$PSScriptRoot\updates\Update-GitDependency.ps1"
    . "$PSScriptRoot\updates\Update-WebDependency.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant BuilderPath ([String]$PSScriptRoot)

    Set-Variable -Option Constant TestResourcesPath ([String]'TEST_RESOURCES_PATH')
    Set-Variable -Option Constant TestWipPath ([String]'TEST_WIP_PATH')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')
    Set-Variable -Option Constant TestDependenciesFile ([String]"$TestResourcesPath\dependencies.json")
    Set-Variable -Option Constant TestUrlsFile ([String]"$TestResourcesPath\urls.json")

    Set-Variable -Option Constant SourceGitHub ([String]'GitHub')
    Set-Variable -Option Constant SourceGitLab ([String]'GitLab')
    Set-Variable -Option Constant SourceFile ([String]'File')
    Set-Variable -Option Constant SourceURL ([String]'URL')
    Set-Variable -Option Constant TestDependencyName ([String]'TEST_DEPENDENCY_NAME')

    Set-Variable -Option Constant TestDependencyVersion ([String]'1.0.0')
    Set-Variable -Option Constant TestNewVersion ([String]'2.0.0')

    Set-Variable -Option Constant TestGitHubChangelogUrl ([String[]]@('TEST_GITHUB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestGitLabChangelogUrl ([String[]]@('TEST_GITLAB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestWebChangelogUrl ([String[]]@('TEST_WEB_CHANGELOG_URL'))

    # A fresh object for every read — the updaters change the version of the dependency they are given
    function New-TestDependency {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Source,
            [Parameter(Position = 1)][String]$Name = $TestDependencyName
        )

        return [Dependency]@{ source = $Source; name = $Name; version = $TestDependencyVersion }
    }
}

Describe 'Update-Dependencies' {
    BeforeAll {
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Read-GitHubToken { return $TestGitHubToken }
        Mock Read-JsonFile { return @(New-TestDependency $SourceGitHub) }
        # Like the real updaters: changelog links come only with a new version...
        Mock Update-GitDependency {
            $Dependency.version = $TestNewVersion
            return $TestGitHubChangelogUrl
        } -ParameterFilter { $Dependency.source -eq $SourceGitHub }
        Mock Update-GitDependency {
            $Dependency.version = $TestNewVersion
            return $TestGitLabChangelogUrl
        } -ParameterFilter { $Dependency.source -eq $SourceGitLab }
        Mock Update-WebDependency {
            $Dependency.version = $TestNewVersion
            return $TestWebChangelogUrl
        }
        # ...and a new file dependency version comes with none at all
        Mock Update-FileDependency { $Dependency.version = $TestNewVersion }
        Mock Update-DependencyChecksum { return $True }
        Mock Write-JsonFile {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should not save anything when no version changes' {
        Mock Update-GitDependency {} -ParameterFilter { $Dependency.source -eq $SourceGitHub }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Update-DependencyChecksum -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update the checksum of a dependency whose version changes' {
        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeExactly $TestGitHubChangelogUrl

        Should -Invoke Update-DependencyChecksum -Exactly 1
        Should -Invoke Update-DependencyChecksum -Exactly 1 -ParameterFilter {
            $Dependency.name -eq $TestDependencyName -and
            $Dependency.version -eq $TestNewVersion -and
            $UrlsFile -eq $TestUrlsFile
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter { $Content[0].version -eq $TestNewVersion }
    }

    It 'Should keep the previous version when the checksum of the new one cannot be computed' {
        Mock Update-DependencyChecksum { return $False }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Update-DependencyChecksum -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -eq "Keeping '$TestDependencyName' at version $TestDependencyVersion" }
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update GitHub dependencies successfully when GitHub token is provided' {
        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeExactly $TestGitHubChangelogUrl

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1 -ParameterFilter { $EnvPath -eq '.env' }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq $TestDependenciesFile }
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1 -ParameterFilter {
            $GitHubToken -eq $TestGitHubToken -and
            $Dependency.source -eq $SourceGitHub -and
            $Dependency.name -eq $TestDependencyName
        }
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceGitHub -and
            $Content[0].name -eq $TestDependencyName -and
            $Content[0].version -eq $TestNewVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update GitHub dependencies successfully when no GitHub token is provided' {
        Mock Read-GitHubToken {}

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeExactly $TestGitHubChangelogUrl

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1 -ParameterFilter {
            $GitHubToken -eq '' -and
            $Dependency.source -eq $SourceGitHub
        }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should flatten and sort multiple changelog URLs from a single dependency' {
        Mock Update-GitDependency {
            $Dependency.version = $TestNewVersion
            return @('TEST_URL_B', 'TEST_URL_A')
        } -ParameterFilter { $Dependency.source -eq $SourceGitHub }

        $Result = Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath

        $Result | Should -HaveCount 2
        $Result[0] | Should -BeExactly 'TEST_URL_A'
        $Result[1] | Should -BeExactly 'TEST_URL_B'

        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should deduplicate changelog URLs across multiple dependencies' {
        Mock Read-JsonFile { return @((New-TestDependency $SourceGitHub 'dep1'), (New-TestDependency $SourceURL 'dep2')) }
        Mock Update-GitDependency {
            $Dependency.version = $TestNewVersion
            return @('TEST_URL_A')
        } -ParameterFilter { $Dependency.source -eq $SourceGitHub }
        Mock Update-WebDependency {
            $Dependency.version = $TestNewVersion
            return @('TEST_URL_A')
        }

        $Result = Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath

        $Result | Should -HaveCount 1
        $Result | Should -BeExactly 'TEST_URL_A'

        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update GitLab dependencies' {
        Mock Read-JsonFile { return @(New-TestDependency $SourceGitLab) }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeExactly $TestGitLabChangelogUrl

        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1 -ParameterFilter {
            $GitHubToken -eq $Null -and
            $Dependency.source -eq $SourceGitLab -and
            $Dependency.name -eq $TestDependencyName
        }
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceGitLab -and
            $Content[0].version -eq $TestNewVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update web dependencies' {
        Mock Read-JsonFile { return @(New-TestDependency $SourceURL) }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeExactly $TestWebChangelogUrl

        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 1 -ParameterFilter {
            $Dependency.source -eq $SourceURL -and
            $Dependency.name -eq $TestDependencyName
        }
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceURL -and
            $Content[0].version -eq $TestNewVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should save a new file dependency version, which comes without changelog links' {
        Mock Read-JsonFile { return @(New-TestDependency $SourceFile) }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeNullOrEmpty

        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 1
        Should -Invoke Update-FileDependency -Exactly 1 -ParameterFilter {
            $WipPath -eq $TestWipPath -and
            $Dependency.source -eq $SourceFile -and
            $Dependency.name -eq $TestDependencyName
        }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceFile -and
            $Content[0].version -eq $TestNewVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Read-GitHubToken failure' {
        Mock Read-GitHubToken { throw $TestException }

        { Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 0
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException }

        { Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should return early when dependencies file is empty' {
        Mock Read-JsonFile { return @() }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -ParameterFilter { $Message -eq 'No dependencies found in configuration file.' }
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should return early when dependencies file returns null' {
        Mock Read-JsonFile { return $Null }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -ParameterFilter { $Message -eq 'No dependencies found in configuration file.' }
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should keep the updates of the other dependencies when one cannot be checked' {
        Mock Read-JsonFile { return @((New-TestDependency $SourceGitHub 'dep1'), (New-TestDependency $SourceURL 'dep2')) }
        Mock Update-GitDependency { throw $TestException } -ParameterFilter { $Dependency.source -eq $SourceGitHub }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeExactly $TestWebChangelogUrl

        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -match "Failed to check 'dep1' for updates" }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Content[0].version -eq $TestDependencyVersion -and
            $Content[1].version -eq $TestNewVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should restore the version of a dependency whose check fails midway' {
        Mock Read-JsonFile { return @((New-TestDependency $SourceGitHub 'dep1'), (New-TestDependency $SourceURL 'dep2')) }
        Mock Update-DependencyChecksum { throw $TestException } -ParameterFilter { $Dependency.name -eq 'dep1' }

        Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath | Should -BeExactly $TestWebChangelogUrl

        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Content[0].version -eq $TestDependencyVersion -and
            $Content[1].version -eq $TestNewVersion
        }
    }

    It 'Should handle Update-GitDependency failure with a GitHub source' {
        Mock Update-GitDependency { throw $TestException } -ParameterFilter { $Dependency.source -eq $SourceGitHub }

        { Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath } | Should -Throw 'Failed to check any dependency for updates'

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Update-GitDependency failure with a GitLab source' {
        Mock Read-JsonFile { return @(New-TestDependency $SourceGitLab) }
        Mock Update-GitDependency { throw $TestException } -ParameterFilter { $Dependency.source -eq $SourceGitLab }

        { Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath } | Should -Throw 'Failed to check any dependency for updates'

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Update-WebDependency failure' {
        Mock Read-JsonFile { return @(New-TestDependency $SourceURL) }
        Mock Update-WebDependency { throw $TestException }

        { Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath } | Should -Throw 'Failed to check any dependency for updates'

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Update-FileDependency failure' {
        Mock Read-JsonFile { return @(New-TestDependency $SourceFile) }
        Mock Update-FileDependency { throw $TestException }

        { Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath } | Should -Throw 'Failed to check any dependency for updates'

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Update-FileDependency -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-JsonFile failure' {
        Mock Write-JsonFile { throw $TestException }

        { Update-Dependencies $TestResourcesPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
