BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
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
    Set-Variable -Option Constant TestGitHubDependency ([String]"[{'source':'$SourceGitHub','name':'$TestDependencyName','version':'$TestDependencyVersion'}]")
    Set-Variable -Option Constant TestGitLabDependency ([String]"[{'source':'$SourceGitLab','name':'$TestDependencyName','version':'$TestDependencyVersion'}]")
    Set-Variable -Option Constant TestWebDependency ([String]"[{'source':'$SourceURL','name':'$TestDependencyName','version':'$TestDependencyVersion'}]")
    Set-Variable -Option Constant TestFileDependency ([String]"[{'source':'$SourceFile','name':'$TestDependencyName','version':'$TestDependencyVersion'}]")

    Set-Variable -Option Constant TestNewDependencyVersion ([String]'1.1.0')
    Set-Variable -Option Constant TestGitHubUpdatedDependency ([String]"[{'source':'$SourceGitHub','name':'$TestDependencyName','version':'$TestNewDependencyVersion'}]")
    Set-Variable -Option Constant TestGitLabUpdatedDependency ([String]"[{'source':'$SourceGitLab','name':'$TestDependencyName','version':'$TestNewDependencyVersion'}]")
    Set-Variable -Option Constant TestWebUpdatedDependency ([String]"[{'source':'$SourceURL','name':'$TestDependencyName','version':'$TestNewDependencyVersion'}]")
    Set-Variable -Option Constant TestFileUpdatedDependency ([String]"[{'source':'$SourceFile','name':'$TestDependencyName','version':'$TestNewDependencyVersion'}]")

    Set-Variable -Option Constant TestGitHubChangelogUrl ([Collections.Generic.List[String]]@('TEST_GITHUB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestGitLabChangelogUrl ([Collections.Generic.List[String]]@('TEST_GITLAB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestWebChangelogUrl ([Collections.Generic.List[String]]@('TEST_WEB_CHANGELOG_URL'))
    Set-Variable -Option Constant TestFileChangelogUrl ([Collections.Generic.List[String]]@('TEST_FILE_CHANGELOG_URL'))
}

Describe 'Update-Dependencies' {
    BeforeEach {
        Mock Write-Progress {}
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Read-GitHubToken { return $TestGitHubToken }
        Mock Get-Content { return $TestGitHubDependency }
        Mock Update-GitDependency { return $TestGitHubChangelogUrl } -ParameterFilter { $Dependency.source -eq $SourceGitHub }
        Mock Update-GitDependency { return $TestGitLabChangelogUrl } -ParameterFilter { $Dependency.source -eq $SourceGitLab }
        Mock Update-WebDependency { return $TestWebChangelogUrl }
        Mock Update-FileDependency { return $TestFileChangelogUrl }
        Mock ConvertTo-Json { return $TestGitHubUpdatedDependency } -ParameterFilter { $InputObject.source -eq $SourceGitHub }
        Mock ConvertTo-Json { return $TestGitLabUpdatedDependency } -ParameterFilter { $InputObject.source -eq $SourceGitLab }
        Mock ConvertTo-Json { return $TestWebUpdatedDependency } -ParameterFilter { $InputObject.source -eq $SourceURL }
        Mock ConvertTo-Json { return $TestFileUpdatedDependency } -ParameterFilter { $InputObject.source -eq $SourceFile }
        Mock Start-Process {}
        Mock Set-Content {}
        Mock Out-Success {}
    }

    It 'Should update GitHub dependencies successfully when GitHub token is provided' {
        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Read-GitHubToken -Exactly 1 -ParameterFilter { $EnvPath -eq '.env' }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
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
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Value -eq $TestGitHubUpdatedDependency -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should update GitHub dependencies successfully when no GitHub token is provided' {
        Mock Read-GitHubToken {}

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Get-Content -Exactly 1
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
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Value -eq $TestGitHubUpdatedDependency -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should update GitLab dependencies successfully' {
        Mock Get-Content { return $TestGitLabDependency }

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
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
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Value -eq $TestGitLabUpdatedDependency -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should update web dependencies successfully' {
        Mock Get-Content { return $TestWebDependency }

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
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
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Value -eq $TestWebUpdatedDependency -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should update file dependencies successfully' {
        Mock Get-Content { return $TestFileDependency }

        Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
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
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestDependenciesFile -and
            $Value -eq $TestFileUpdatedDependency -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Read-GitHubToken failure' {
        Mock Read-GitHubToken { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Update-GitDependency failure with a GitHub source' {
        Mock Get-Content { return $TestGitHubDependency }
        Mock Update-GitDependency { throw $TestException } -ParameterFilter { $Dependency.source -eq $SourceGitHub }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Update-GitDependency failure with a GitLab source' {
        Mock Get-Content { return $TestGitLabDependency }
        Mock Update-GitDependency { throw $TestException } -ParameterFilter { $Dependency.source -eq $SourceGitLab }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Update-WebDependency failure' {
        Mock Get-Content { return $TestWebDependency }
        Mock Update-WebDependency { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 1
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Update-FileDependency failure' {
        Mock Get-Content { return $TestFileDependency }
        Mock Update-FileDependency { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 0
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Update-Dependencies $TestConfigPath $BuilderPath $TestWipPath } | Should -Throw

        Should -Invoke Read-GitHubToken -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Update-GitDependency -Exactly 1
        Should -Invoke Update-WebDependency -Exactly 0
        Should -Invoke Update-FileDependency -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
