BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\Common\Backup-File.ps1"
    . "$PSScriptRoot\..\..\Common\New-Directory.ps1"
    . "$PSScriptRoot\..\..\Common\Write-Utf8File.ps1"
    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\Stop-ProcessIfRunning.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestParentPath ([String]'TEST_PATH_PARENT')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestContent ([String]'TEST_CONTENT')
    Set-Variable -Option Constant TestPath ([String]"$TestParentPath\TEST_PATH_CHILD")
}

Describe 'Write-ConfigurationFile' {
    BeforeAll {
        Mock Stop-ProcessIfRunning {}
        Mock Write-LogInfo {}
        Mock Split-Path { return $TestParentPath }
        Mock New-Directory {}
        Mock Backup-File {}
        Mock Write-Utf8File {}
        Mock Out-Success {}
        Mock Write-LogWarning {}
    }

    It 'Should write configuration file' {
        Write-ConfigurationFile $TestAppName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1 -ParameterFilter { $ProcessName -eq $TestAppName }
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke Split-Path -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Parent -eq $True
        }
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter {
            $Path -eq $TestParentPath
        }
        Should -Invoke Backup-File -Exactly 1
        Should -Invoke Backup-File -Exactly 1 -ParameterFilter { $Path -eq $TestPath }
        Should -Invoke Write-Utf8File -Exactly 1
        Should -Invoke Write-Utf8File -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Content -eq $TestContent
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Stop-ProcessIfRunning failure' {
        Mock Stop-ProcessIfRunning { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Split-Path -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Write-Utf8File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Split-Path failure' {
        Mock Split-Path { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Write-Utf8File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Write-Utf8File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should not overwrite a file it could not keep a copy of' {
        Mock Backup-File { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath } | Should -Throw $TestException

        Should -Invoke Backup-File -Exactly 1
        Should -Invoke Write-Utf8File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Write-Utf8File failure' {
        Mock Write-Utf8File { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Write-Utf8File -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }
}
