BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\Common\Network.ps1"
    . "$PSScriptRoot\..\Common\Start-Download.ps1"
    . "$PSScriptRoot\Initialize-AppDirectory.ps1"
    . "$PSScriptRoot\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant VERSION ([Version]'1.0.0')
    Set-Variable -Option Constant PATH_WORKING_DIR ([String]'TEST_PATH_WORKING_DIR')
    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')

    Set-Variable -Option Constant TestAppBatFile ([String]"$PATH_WORKING_DIR\qiiwexc.bat")
    Set-Variable -Option Constant TestDownloadedFile ([String]"$PATH_APP_DIR\qiiwexc.bat")
    Set-Variable -Option Constant TestChecksumsFile ([String]"$PATH_APP_DIR\SHA256SUMS.txt")
    Set-Variable -Option Constant TestChecksum ([String]'cdae978a55d34e99dd4385eee0377cf1387549a3b78c5acd2a81c868a57cab45')
    Set-Variable -Option Constant TestChecksums ([String]"0bd3603d7d149672454a983ee3a5f30b26f4587755cb012c88bb3bf73a131b16  qiiwexc.ps1`n$TestChecksum  qiiwexc.bat`n42be0a0451555231ea6bc15ea74ed84069e02335be7229307847ed07c5568703  autounattend-English.xml`n")
}

Describe 'Test-UpdateAvailability' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Out-Status {}
        Mock Test-NetworkConnection { return $True }
        Mock Invoke-WebRequest { return @{ Content = '[{"tag_name":"v2.0.0","prerelease":false,"draft":false}]' } }
        Mock Out-Failure {}
        Mock Write-LogWarning {}
    }

    BeforeEach {
        [Bool]$DevMode = $False
    }

    It 'Should detect available update' {
        Test-UpdateAvailability | Should -BeTrue

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq '{URL_VERSION_FILE}' -and
            $UseBasicParsing -eq $True -and
            $TimeoutSec -eq 15
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should detect no available update' {
        Mock Invoke-WebRequest { return @{ Content = '[{"tag_name":"v1.0.0","prerelease":false,"draft":false}]' } }

        Test-UpdateAvailability | Should -BeFalse

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should ignore pre-releases and drafts, which the update download cannot deliver' {
        Mock Invoke-WebRequest { return @{ Content = '[{"tag_name":"v3.0.0","prerelease":true,"draft":false},{"tag_name":"v2.5.0","prerelease":false,"draft":true}]' } }

        Test-UpdateAvailability | Should -BeFalse

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should skip update check in dev mode' {
        [Bool]$DevMode = $True

        Test-UpdateAvailability | Should -BeFalse

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should skip update check when no network connection' {
        Mock Test-NetworkConnection { return $False }

        Test-UpdateAvailability | Should -BeFalse

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        Test-UpdateAvailability | Should -BeFalse

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        Test-UpdateAvailability | Should -BeFalse

        Should -Invoke Out-Status -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }
}

Describe 'Get-NewVersion' {
    BeforeAll {
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Initialize-AppDirectory {}
        Mock Invoke-WebRequest {}
        Mock Get-Content { return $TestChecksums }
        Mock Test-FileChecksum {}
        Mock Move-Item {}
        Mock Out-Failure {}
        Mock Out-Success {}
    }

    It 'Should download and verify the new version of the app' {
        Get-NewVersion $TestAppBatFile | Should -BeTrue

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 2
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq '{URL_BAT_FILE_UPDATE}' -and
            $OutFile -eq $TestDownloadedFile -and
            $UseBasicParsing -eq $True -and
            $TimeoutSec -eq 60
        }
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq '{URL_CHECKSUMS_FILE}' -and
            $OutFile -eq $TestChecksumsFile -and
            $UseBasicParsing -eq $True -and
            $TimeoutSec -eq 15
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter { $Path -eq $TestChecksumsFile }
        Should -Invoke Test-FileChecksum -Exactly 1
        Should -Invoke Test-FileChecksum -Exactly 1 -ParameterFilter {
            $Path -eq $TestDownloadedFile -and
            $Sha256 -eq $TestChecksum
        }
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestDownloadedFile -and
            $Destination -eq $TestAppBatFile -and
            $Force -eq $True
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip download when no network connection' {
        Mock Test-NetworkConnection { return $False }

        Get-NewVersion $TestAppBatFile | Should -BeFalse

        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should not replace the app when the checksums file has no entry for it' {
        Mock Get-Content { return "$TestChecksum  qiiwexc.ps1`n" }

        Get-NewVersion $TestAppBatFile | Should -BeFalse

        Should -Invoke Test-FileChecksum -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should not replace the app when the checksum does not match' {
        Mock Test-FileChecksum { throw $TestException }

        Get-NewVersion $TestAppBatFile | Should -BeFalse

        Should -Invoke Test-FileChecksum -Exactly 1
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should accept checksums files with CRLF line endings' {
        Mock Get-Content { return "$TestChecksum *qiiwexc.bat`r`n" }

        Get-NewVersion $TestAppBatFile | Should -BeTrue

        Should -Invoke Test-FileChecksum -Exactly 1 -ParameterFilter { $Sha256 -eq $TestChecksum }
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        Get-NewVersion $TestAppBatFile | Should -BeFalse

        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Invoke-WebRequest failure' {
        Mock Invoke-WebRequest { throw $TestException }

        Get-NewVersion $TestAppBatFile | Should -BeFalse

        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Test-FileChecksum -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Move-Item failure' {
        Mock Move-Item { throw $TestException }

        Get-NewVersion $TestAppBatFile | Should -BeFalse

        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}

Describe 'Update-App' {
    BeforeAll {
        Mock Test-UpdateAvailability { return $True }
        Mock Get-NewVersion { return $True }
        Mock Write-LogWarning {}
        Mock Start-Process {}
        Mock Out-Failure {}
    }

    It 'Should start the new version of the app' {
        Update-App | Should -BeTrue

        Should -Invoke Test-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 1 -ParameterFilter { $AppBatFile -eq $TestAppBatFile }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -eq 'Restarting...' }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter { $FilePath -eq $TestAppBatFile }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should skip download when no update is available' {
        Mock Test-UpdateAvailability { return $False }

        Update-App | Should -BeFalse

        Should -Invoke Test-UpdateAvailability -Exactly 1
        Should -Invoke Get-NewVersion -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should keep running the current version when the download fails' {
        Mock Get-NewVersion { return $False }

        Update-App | Should -BeFalse

        Should -Invoke Get-NewVersion -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -eq 'Continuing with the current version' }
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        Update-App | Should -BeFalse

        Should -Invoke Get-NewVersion -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
    }
}
