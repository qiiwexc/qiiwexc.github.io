BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\New-Directory.ps1'
    . '.\src\4-functions\Common\Stop-ProcessIfRunning.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestParentPath ([String]'TEST_PATH_PARENT')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestContent ([String]'TEST_CONTENT')
    Set-Variable -Option Constant TestPath ([String]"$TestParentPath\TEST_PATH_CHILD")
    Set-Variable -Option Constant TestProcessName ([String]'TEST_PROCESS_NAME')
}

Describe 'Write-ConfigurationFile' {
    BeforeEach {
        Mock Stop-ProcessIfRunning {}
        Mock Write-LogInfo {}
        Mock Split-Path { return $TestParentPath }
        Mock New-Directory {}
        Mock Set-Content {}
        Mock Out-Success {}
        Mock Write-LogWarning {}
    }

    It 'Should write configuration file' {
        Write-ConfigurationFile $TestAppName $TestContent $TestPath $TestProcessName

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1 -ParameterFilter { $ProcessName -eq $TestProcessName }
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke Split-Path -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Parent -eq $True
        }
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter {
            $Path -eq $TestParentPath
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Value -eq $TestContent -and
            $NoNewline -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should stop correct process when process name is not provided' {
        Write-ConfigurationFile $TestAppName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1 -ParameterFilter { $ProcessName -eq $TestAppName }
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Stop-ProcessIfRunning failure' {
        Mock Stop-ProcessIfRunning { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath $TestProcessName } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 0
        Should -Invoke Split-Path -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should handle Split-Path failure' {
        Mock Split-Path { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath $TestProcessName } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath $TestProcessName } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Write-ConfigurationFile $TestAppName $TestContent $TestPath $TestProcessName } | Should -Throw $TestException

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Split-Path -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }
}
