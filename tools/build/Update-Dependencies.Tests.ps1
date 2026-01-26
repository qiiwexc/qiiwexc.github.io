BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\types.ps1'
    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-JsonFile.ps1'
    . '.\tools\common\Write-JsonFile.ps1'
    . '.\tools\build\updates\Read-GitHubToken.ps1'
    . '.\tools\build\updates\Update-FileDependency.ps1'
    . '.\tools\build\updates\Update-GitDependency.ps1'
    . '.\tools\build\updates\Update-WebDependency.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant BuilderPath ([String]'.\tools\build')

    Set-Variable -Option Constant TestConfigPath ([String]'TEST_CONFIG_PATH')
    Set-Variable -Option Constant TestWipPath ([String]'TEST_WIP_PATH')

    Set-Variable -Option Constant TestGitHubToken ([String]'TEST_GITHUB_TOKEN')
    Set-Variable -Option Constant TestDependenciesFile ([String]"$TestConfigPath\dependencies.json")

    Set-Variable -Option Constant SourceGitHub ([String]'GitHub')
    Set-Variable -Option Constant SourceGitLab ([String]'GitLab')
    Set-Variable -Option Constant SourceFile ([String]'File')
    Set-Variable -Option Constant SourceURL ([String]'URL')
    Set-Variable -Option Constant TestDependencyName ([String]'TEST_DEPENDENCY_NAME')

    Set-Variable -Option Constant TestDependencyVersion ([String]'1.0.0')
    Set-Variable -Option Constant TestGitHubDependency (
        [Dependency[]]@(
            @{source = $SourceGitHub; name = $TestDependencyName; version = $TestDependencyVersion }
        )
    )
    Set-Variable -Option Constant TestGitLabDependency (
        [Dependency[]]@(
            @{source = $SourceGitLab; name = $TestDependencyName; version = $TestDependencyVersion }
        )
    )
    Set-Variable -Option Constant TestWebDependency (
        [Dependency[]]@(
            @{source = $SourceURL; name = $TestDependencyName; version = $TestDependencyVersion }
        )
    )
    Set-Variable -Option Constant TestFileDependency (
        [Dependency[]]@(
            @{source = $SourceFile; name = $TestDependencyName; version = $TestDependencyVersion }
        )
    )

    Set-Variable -Option Constant TestGitHubChangelogUrl ([String[]]@('TEST_GITHUB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestGitLabChangelogUrl ([String[]]@('TEST_GITLAB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestWebChangelogUrl ([String[]]@('TEST_WEB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestFileChangelogUrl ([String[]]@('TEST_FILE_CHANGELOG_URL'))
}

Describe 'Update-Dependencies' {
    BeforeEach {
        Mock New-Activity {}
        Mock Write-ActivityProgress {}
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Read-GitHubToken { return $TestGitHubToken }
        Mock Read-JsonFile { return $TestGitHubDependency }
        Mock Update-GitDependency { return $TestGitHubChangelogUrl } -ParameterFilter { $Dependency.source -eq $SourceGitHub }
        Mock Update-GitDependency { return $TestGitLabChangelogUrl } -ParameterFilter { $Dependency.source -eq $SourceGitLab }
        Mock Update-WebDependency { return $TestWebChangelogUrl }
        Mock Update-FileDependency { return $TestFileChangelogUrl }
        Mock Start-Process {}
        Mock Write-JsonFile {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should update GitHub dependencies successfully when GitHub token is provided' {
        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1 -ParameterFilter { $EnvPath -eq '.env' }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter { $Path -eq $TestDependenciesFile }
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1 -ParameterFilter {
            $GitHubToken -eq $TestGitHubToken -and
            $Dependency.source -eq $SourceGitHub -and
            $Dependency.name -eq $TestDependencyName -and
            $Dependency.version -eq $TestDependencyVersion
        }
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestGitHubChangelogUrl }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceGitHub -and
            $Content[0].name -eq $TestDependencyName -and
            $Content[0].version -eq $TestDependencyVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update GitHub dependencies successfully when no GitHub token is provided' {
        Mock Read-GitHubToken {}

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1 -ParameterFilter {
            $GitHubToken -eq '' -and
            $Dependency.source -eq $SourceGitHub -and
            $Dependency.name -eq $TestDependencyName -and
            $Dependency.version -eq $TestDependencyVersion
        }
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestGitHubChangelogUrl }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update GitLab dependencies' {
        Mock Read-JsonFile { return $TestGitLabDependency }

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1 -ParameterFilter {
            $GitHubToken -eq $Null -and
            $Dependency.source -eq $SourceGitLab -and
            $Dependency.name -eq $TestDependencyName -and
            $Dependency.version -eq $TestDependencyVersion
        }
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestGitLabChangelogUrl }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceGitLab -and
            $Content[0].name -eq $TestDependencyName -and
            $Content[0].version -eq $TestDependencyVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update web dependencies' {
        Mock Read-JsonFile { return $TestWebDependency }

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 1 -ParameterFilter {
            $Dependency.source -eq $SourceURL -and
            $Dependency.name -eq $TestDependencyName -and
            $Dependency.version -eq $TestDependencyVersion
        }
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestWebChangelogUrl }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceURL -and
            $Content[0].name -eq $TestDependencyName -and
            $Content[0].version -eq $TestDependencyVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should update file dependencies' {
        Mock Read-JsonFile { return $TestFileDependency }

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 1
        Should -Invoke Update-FileDependency -Exactly 1 -ParameterFilter {
            $WipPath -eq $TestWipPath -and
            $Dependency.source -eq $SourceFile -and
            $Dependency.name -eq $TestDependencyName -and
            $Dependency.version -eq $TestDependencyVersion
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestFileChangelogUrl }
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Content.Count -eq 1 -and
            $Content[0].source -eq $SourceFile -and
            $Content[0].name -eq $TestDependencyName -and
            $Content[0].version -eq $TestDependencyVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Read-GitHubToken failure' {
        Mock Read-GitHubToken { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 0
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Update-GitDependency failure with a GitHub source' {
        Mock Read-JsonFile { return $TestGitHubDependency }
        Mock Update-GitDependency { throw $TestException } -ParameterFilter { $Dependency.source -eq $SourceGitHub }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Update-GitDependency failure with a GitLab source' {
        Mock Read-JsonFile { return $TestGitLabDependency }
        Mock Update-GitDependency { throw $TestException } -ParameterFilter { $Dependency.source -eq $SourceGitLab }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Update-WebDependency failure' {
        Mock Read-JsonFile { return $TestWebDependency }
        Mock Update-WebDependency { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 1
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Update-FileDependency failure' {
        Mock Read-JsonFile { return $TestFileDependency }
        Mock Update-FileDependency { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 5
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-JsonFile failure' {
        Mock Write-JsonFile { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 6
        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-JsonFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
