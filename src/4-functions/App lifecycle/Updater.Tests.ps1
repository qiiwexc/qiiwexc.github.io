BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\App lifecycle\Exit.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant VERSION ([Version]'1.0.0')
    Set-Variable -Option Constant PATH_WORKING_DIR ([String]'TEST_PATH_WORKING_DIR')

    Set-Variable -Option Constant TestAppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")
}

Describe 'Get-UpdateAvailability' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Out-Status {}
        Mock Test-NetworkConnection { return $True }
        Mock Invoke-WebRequest { return '2.0.0' }
        Mock Out-Failure {}
        Mock Write-LogWarning {}

        [Bool]$DevMode = $False
    }

    It 'Should detect available update' {
        Get-UpdateAvailability

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq '{URL_VERSION_FILE}' -and
            $UseBasicParsing -eq $True
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should detect no available update' {
        Mock Invoke-WebRequest { return $VERSION }

        Get-UpdateAvailability

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq '{URL_VERSION_FILE}' -and
            $UseBasicParsing -eq $True
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should skip update check in dev mode' {
        [Bool]$DevMode = $True

        Get-UpdateAvailability

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should skip update check when no network connection' {
        Mock Test-NetworkConnection { return $False }

        Get-UpdateAvailability

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        Get-UpdateAvailability

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        Get-UpdateAvailability

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }
}

Describe 'Get-NewVersion' {
    BeforeEach {
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Invoke-WebRequest {}
        Mock Out-Failure {}
        Mock Out-Success {}
    }

    It 'Should download new version of the app' {
        Get-NewVersion $TestAppBatFile

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq '{URL_BAT_FILE}' -and
            $OutFile -eq $TestAppBatFile
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip download when no network connection' {
        Mock Test-NetworkConnection { return $False }

        Get-NewVersion $TestAppBatFile

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        Get-NewVersion $TestAppBatFile

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        Get-NewVersion $TestAppBatFile

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}

Describe 'Update-App' {
    BeforeEach {
        Mock Get-UpdateAvailability { return $True }
        Mock Get-NewVersion {}
        Mock Write-LogWarning {}
        Mock Invoke-CustomCommand {}
        Mock Out-Failure {}
        Mock Exit-App {}
    }

    It 'Should download new version of the app' {
        Update-App

        Should -Invoke Get-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 1 -ParameterFilter { $AppBatFile -eq $TestAppBatFile }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -eq $TestAppBatFile }
        Should -Invoke Exit-App -Exactly 1
        Should -Invoke Exit-App -Exactly 1 -ParameterFilter { $Update -eq $True }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should skip download when no update is available' {
        Mock Get-UpdateAvailability { return $False }

        Update-App

        Should -Invoke Get-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Exit-App -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Get-UpdateAvailability failure' {
        Mock Get-UpdateAvailability { throw $TestException }

        Update-App

        Should -Invoke Get-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Exit-App -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Get-NewVersion failure' {
        Mock Get-NewVersion { throw $TestException }

        Update-App

        Should -Invoke Get-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Exit-App -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        Update-App

        Should -Invoke Get-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Exit-App -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Exit-App failure' {
        Mock Exit-App { throw $TestException }

        Update-App

        Should -Invoke Get-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Exit-App -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
    }
}
