BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Stop-ProcessIfRunning.ps1'
    . '.\src\4-functions\Configuration\Helpers\Merge-JsonObject.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestProcessName ([String]'TEST_PROCESS_NAME')
    Set-Variable -Option Constant TestContent ([String]'{"TEST_KEY_NEW":"TEST_VALUE_NEW"}')
    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')

    Set-Variable -Option Constant TestExistingConfig ([String]'{"TEST_KEY_EXISTING":"TEST_VALUE_EXISTING"}')
    Set-Variable -Option Constant TestUpdatedConfig ([String]'{"TEST_KEY_EXISTING":"TEST_VALUE_EXISTING","TEST_KEY_NEW":"TEST_VALUE_NEW"}')

    Set-Variable -Option Constant TestContentObject ([PSCustomObject]@{TEST_KEY_NEW = 'TEST_VALUE_NEW' })
    Set-Variable -Option Constant TestExistingConfigObject ([PSCustomObject]@{TEST_KEY_EXISTING = 'TEST_VALUE_EXISTING' })
    Set-Variable -Option Constant TestUpdatedConfigObject ([PSCustomObject]@{TEST_KEY_EXISTING = 'TEST_VALUE_EXISTING'; TEST_KEY_NEW = 'TEST_VALUE_NEW' })
}

Describe 'Update-BrowserConfiguration' {
    BeforeEach {
        [Int]$script:TestPathCounter = 0
        [Int]$TestPathSuccessIteration = 0

        Mock Write-LogInfo {}
        Mock Stop-ProcessIfRunning {}
        Mock Test-Path {
            $script:TestPathCounter++
            return $script:TestPathCounter -ge $TestPathSuccessIteration
        }
        Mock Start-Process {}
        Mock Write-LogError {}
        Mock Start-Sleep {}
        Mock Get-Content { return $TestExistingConfig }
        Mock Merge-JsonObject { return $TestUpdatedConfigObject }
        Mock Set-Content {}
        Mock Out-Success {}
    }

    It 'Should update browser configuration file if profile exists' {
        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1 -ParameterFilter { $ProcessName -eq $TestProcessName }
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestPath }
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogError -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Encoding -eq 'UTF8' -and
            $Raw -eq $True
        }
        Should -Invoke Merge-JsonObject -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 1 -ParameterFilter {
            $Source.TEST_KEY_EXISTING -eq 'TEST_VALUE_EXISTING' -and
            $Extend.TEST_KEY_NEW -eq 'TEST_VALUE_NEW'
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Value -eq $TestUpdatedConfig -and
            $Encoding -eq 'UTF8' -and
            $NoNewline -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should update browser configuration file if profile does not exist' {
        [Int]$TestPathSuccessIteration = 3

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1 -ParameterFilter { $ProcessName -eq $TestProcessName }
        Should -Invoke Test-Path -Exactly 3
        Should -Invoke Test-Path -Exactly 3 -ParameterFilter { $Path -eq $TestPath }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestProcessName }
        Should -Invoke Write-LogError -Exactly 0
        Should -Invoke Start-Sleep -Exactly 2
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Encoding -eq 'UTF8' -and
            $Raw -eq $True
        }
        Should -Invoke Merge-JsonObject -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 1 -ParameterFilter {
            $Source.TEST_KEY_EXISTING -eq 'TEST_VALUE_EXISTING' -and
            $Extend.TEST_KEY_NEW -eq 'TEST_VALUE_NEW'
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPath -and
            $Value -eq $TestUpdatedConfig -and
            $Encoding -eq 'UTF8' -and
            $NoNewline -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Stop-ProcessIfRunning failure' {
        Mock Stop-ProcessIfRunning { throw $TestException }

        { Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogError -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        { Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogError -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        [Int]$TestPathSuccessIteration = 2

        Mock Start-Process { throw $TestException }

        { Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-LogError -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogError -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Merge-JsonObject failure' {
        Mock Merge-JsonObject { throw $TestException }

        { Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogError -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogError -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
