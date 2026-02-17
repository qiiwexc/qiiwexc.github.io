BeforeAll {
    # Define untyped stubs before BitsTransfer module auto-loads,
    # so Pester mocks use simple parameters instead of the module's typed [BitsJob[]] constraint
    function Complete-BitsTransfer { param($BitsJob) }
    function Remove-BitsTransfer { param($BitsJob) }

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\App lifecycle\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_TEMP_DIR')
    Set-Variable -Option Constant PATH_WORKING_DIR ([String]'TEST_TEMP_DIR')

    Set-Variable -Option Constant TestUrlLeaf ([String]'TEST_URL_LEAF')
    Set-Variable -Option Constant TestUrl ([String]"TEST_URL_PARENT/$TestUrlLeaf")
    Set-Variable -Option Constant TestSaveAs ([String]'TEST_SAVE_AS')

    Set-Variable -Option Constant TestTempPath ([String]"$PATH_APP_DIR\$TestUrlLeaf")
    Set-Variable -Option Constant TestTempPathSaveAs ([String]"$PATH_APP_DIR\$TestSaveAs")

    Set-Variable -Option Constant TestSavePath ([String]"$PATH_WORKING_DIR\$TestUrlLeaf")
    Set-Variable -Option Constant TestSavePathSaveAs ([String]"$PATH_WORKING_DIR\$TestSaveAs")
}

Describe 'Start-Download' {
    BeforeEach {
        # Test-Path counter mock: returns False until call N, then True from call N onward.
        # Set FileAppearsAtCall=2 for download tests (call 1 = not cached, call 2+ = file exists).
        # Default (1) means file exists immediately (already downloaded scenario).
        [Int]$script:TestPathCalls = 0
        [Int]$FileAppearsAtCall = 1

        Mock Write-ActivityProgress {}
        Mock Test-Path {
            $script:TestPathCalls++
            return $script:TestPathCalls -ge $FileAppearsAtCall
        }
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Initialize-AppDirectory {}
        Mock Start-BitsTransfer { return [PSCustomObject]@{ JobState = 'Transferred'; BytesTotal = 0; BytesTransferred = 0; ErrorDescription = '' } }
        Mock Complete-BitsTransfer {}
        Mock Get-Item { return [PSCustomObject]@{ Length = 1024 } }
        Mock Invoke-WebRequest {}
        Mock Remove-BitsTransfer {}
        Mock Remove-Item {}
        Mock Start-Sleep {}
        Mock Move-Item {}
        Mock Out-Success {}
    }

    It 'Should download file' {
        [Int]$FileAppearsAtCall = 2

        Start-Download $TestUrl | Should -BeExactly $TestSavePath

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Test-Path -Exactly 3
        Should -Invoke Test-Path -Exactly 3 -ParameterFilter { $Path -eq $TestSavePath }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1 -ParameterFilter {
            $Source -eq $TestUrl -and
            $Destination -eq $TestTempPath -and
            $Asynchronous -eq $True
        }
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestTempPath -and
            $Destination -eq $TestSavePath -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download file with custom save path' {
        [Int]$FileAppearsAtCall = 2

        Start-Download $TestUrl $TestSaveAs | Should -BeExactly $TestSavePathSaveAs

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Test-Path -Exactly 3
        Should -Invoke Test-Path -Exactly 3 -ParameterFilter { $Path -eq $TestSavePathSaveAs }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1 -ParameterFilter {
            $Source -eq $TestUrl -and
            $Destination -eq $TestTempPathSaveAs -and
            $Asynchronous -eq $True
        }
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestTempPathSaveAs -and
            $Destination -eq $TestSavePathSaveAs -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download file to temporary path' {
        [Int]$FileAppearsAtCall = 2

        Start-Download $TestUrl -Temp | Should -BeExactly $TestSavePath

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Test-Path -Exactly 3
        Should -Invoke Test-Path -Exactly 3 -ParameterFilter { $Path -eq $TestTempPath }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Invoke-WebRequest -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should return existing file if already downloaded' {
        Start-Download $TestUrl | Should -BeExactly $TestSavePath

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestTempPath }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should throw if no network connection' {
        Mock Test-NetworkConnection { return $False }

        [Int]$FileAppearsAtCall = 2

        { Start-Download $TestUrl } | Should -Throw 'No network connection detected'

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should throw if download fails' {
        # Test-Path sequence: False (not cached), True (BITS file exists), False (final validation fails)
        [Bool[]]$script:PathResults = @($False, $True, $False)
        [Int]$script:TestPathCalls = 0
        Mock Test-Path {
            $script:TestPathCalls++
            return $script:PathResults[$script:TestPathCalls - 1]
        }

        { Start-Download $TestUrl } | Should -Throw 'Possibly computer is offline or disk is full'

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Test-Path -Exactly 3
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 0
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        [Int]$FileAppearsAtCall = 2

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        [Int]$FileAppearsAtCall = 2

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should retry download on failure' {
        $script:BitsTransferAttempts = 0
        Mock Start-BitsTransfer {
            $script:BitsTransferAttempts++
            if ($script:BitsTransferAttempts -lt 2) {
                throw 'Transient error'
            }
            return [PSCustomObject]@{ JobState = 'Transferred'; BytesTotal = 0; BytesTransferred = 0; ErrorDescription = '' }
        }

        [Int]$FileAppearsAtCall = 2

        Start-Download $TestUrl  | Should -BeExactly $TestSavePath

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Test-Path -Exactly 3
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 2
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Start-Sleep -Exactly 1
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Start-BitsTransfer failure' {
        Mock Start-BitsTransfer { throw $TestException }

        [Int]$FileAppearsAtCall = 2

        { Start-Download $TestUrl } | Should -Throw 'Download failed after 3 attempts*'

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 4
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 3
        Should -Invoke Start-Sleep -Exactly 2
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Move-Item failure' {
        Mock Move-Item { throw $TestException }

        [Int]$FileAppearsAtCall = 2

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 3
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should fallback to WebRequest when BITS returns empty file' {
        [Int]$FileAppearsAtCall = 2
        Mock Get-Item { return [PSCustomObject]@{ Length = 0 } }

        Start-Download $TestUrl | Should -BeExactly $TestSavePath

        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Get-Item -Exactly 2
        Should -Invoke Remove-Item -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq $TestUrl -and
            $OutFile -eq $TestTempPath -and
            $UseBasicParsing -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download file using WebRequest when NoBits is specified' {
        [Int]$FileAppearsAtCall = 2

        Start-Download $TestUrl -NoBits | Should -BeExactly $TestSavePath

        Should -Invoke Write-ActivityProgress -Exactly 4
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Complete-BitsTransfer -Exactly 0
        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1
        Should -Invoke Invoke-WebRequest -Exactly 1 -ParameterFilter {
            $Uri -eq $TestUrl -and
            $OutFile -eq $TestTempPath -and
            $UseBasicParsing -eq $True
        }
        Should -Invoke Start-Sleep -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should throw when BITS transfer enters error state' {
        Mock Start-BitsTransfer { return [PSCustomObject]@{ JobState = 'Error'; BytesTotal = 0; BytesTransferred = 0; ErrorDescription = 'Transfer failed' } }

        [Int]$FileAppearsAtCall = 2

        { Start-Download $TestUrl } | Should -Throw 'Download failed after 3 attempts*'

        Should -Invoke Start-BitsTransfer -Exactly 3
        Should -Invoke Complete-BitsTransfer -Exactly 0
        Should -Invoke Remove-BitsTransfer -Exactly 3
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should track progress during BITS transfer' {
        $script:MockBitsJob = [PSCustomObject]@{
            JobState         = 'Transferring'
            BytesTotal       = 100
            BytesTransferred = 50
            ErrorDescription = ''
        }
        Mock Start-BitsTransfer { return $script:MockBitsJob }
        Mock Start-Sleep {
            # After first sleep tick, mark transfer as complete
            $script:MockBitsJob.JobState = 'Transferred'
            $script:MockBitsJob.BytesTransferred = 100
        } -ParameterFilter { $Milliseconds -eq 200 }

        [Int]$FileAppearsAtCall = 2

        Start-Download $TestUrl | Should -BeExactly $TestSavePath

        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Complete-BitsTransfer -Exactly 1
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Invoke-WebRequest failure when NoBits is specified' {
        Mock Invoke-WebRequest { throw $TestException }

        [Int]$FileAppearsAtCall = 2

        { Start-Download $TestUrl -NoBits } | Should -Throw 'Download failed after 3 attempts*'

        Should -Invoke Invoke-WebRequest -Exactly 3
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }
}
