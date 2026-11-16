BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\..\Common\Start-FromShell.ps1"
    . "$PSScriptRoot\Get-AppExecutablePath.ps1"
    . "$PSScriptRoot\Merge-JsonObject.ps1"
    . "$PSScriptRoot\Stop-ProcessIfRunning.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestProcessName ([String]'TEST_PROCESS_NAME')
    Set-Variable -Option Constant TestExecutable ([String]'C:\TEST_DIR\TEST_PROCESS_NAME.exe')
    Set-Variable -Option Constant TestContent ([String]'{"TEST_KEY_NEW":"TEST_VALUE_NEW"}')
    Set-Variable -Option Constant TestPath ([String]'TEST_PATH')

    Set-Variable -Option Constant TestExistingConfig ([String]'{"TEST_KEY_EXISTING":"TEST_VALUE_EXISTING"}')
    Set-Variable -Option Constant TestUpdatedConfig ([String]'{"TEST_KEY_EXISTING":"TEST_VALUE_EXISTING","TEST_KEY_NEW":"TEST_VALUE_NEW"}')

    Set-Variable -Option Constant TestContentObject ([PSCustomObject]@{TEST_KEY_NEW = 'TEST_VALUE_NEW' })
    Set-Variable -Option Constant TestExistingConfigObject ([PSCustomObject]@{TEST_KEY_EXISTING = 'TEST_VALUE_EXISTING' })
    Set-Variable -Option Constant TestUpdatedConfigObject ([PSCustomObject]@{TEST_KEY_EXISTING = 'TEST_VALUE_EXISTING'; TEST_KEY_NEW = 'TEST_VALUE_NEW' })
}

Describe 'Update-BrowserConfiguration' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Stop-ProcessIfRunning {}
        Mock Test-Path {
            $script:TestPathCounter++
            return $script:TestPathCounter -ge $TestPathSuccessIteration
        }
        Mock Get-AppExecutablePath { return $TestExecutable }
        Mock Start-FromShell {}
        Mock Out-Failure {}
        Mock Start-Sleep {}
        Mock Get-Content { return $TestExistingConfig }
        Mock Merge-JsonObject { return $TestUpdatedConfigObject }
        Mock Set-Content {}
        Mock Out-Success {}
    }

    BeforeEach {
        [Int]$script:TestPathCounter = 0
        [Int]$TestPathSuccessIteration = 0
    }

    It 'Should update browser configuration file if profile exists' {
        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Stop-ProcessIfRunning -Exactly 1 -ParameterFilter { $ProcessName -eq $TestProcessName }
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestPath }
        Should -Invoke Start-FromShell -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
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

        # Once before launching the browser to create the profile, and again before writing to it
        Should -Invoke Stop-ProcessIfRunning -Exactly 2
        Should -Invoke Stop-ProcessIfRunning -Exactly 2 -ParameterFilter { $ProcessName -eq $TestProcessName }
        Should -Invoke Test-Path -Exactly 3
        Should -Invoke Test-Path -Exactly 3 -ParameterFilter { $Path -eq $TestPath }
        Should -Invoke Get-AppExecutablePath -Exactly 1
        Should -Invoke Get-AppExecutablePath -Exactly 1 -ParameterFilter { $ExecutableName -eq "$TestProcessName.exe" }
        Should -Invoke Start-FromShell -Exactly 1
        Should -Invoke Start-FromShell -Exactly 1 -ParameterFilter { $Target -eq $TestExecutable }
        Should -Invoke Out-Failure -Exactly 0
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

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 0
        Should -Invoke Start-FromShell -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-FromShell -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should fail without starting anything when the browser is not installed' {
        [Int]$TestPathSuccessIteration = 2

        Mock Get-AppExecutablePath { return '' }

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Get-AppExecutablePath -Exactly 1
        Should -Invoke Start-FromShell -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -like "*'$TestAppName' is not installed*" }
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Start-FromShell failure' {
        [Int]$TestPathSuccessIteration = 2

        Mock Start-FromShell { throw $TestException }

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-FromShell -Exactly 1
        Should -Invoke Out-Failure -Exactly 2
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-FromShell -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Merge-JsonObject failure' {
        Mock Merge-JsonObject { throw $TestException }

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-FromShell -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        Update-BrowserConfiguration $TestAppName $TestProcessName $TestContent $TestPath

        Should -Invoke Stop-ProcessIfRunning -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Start-FromShell -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Merge-JsonObject -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
