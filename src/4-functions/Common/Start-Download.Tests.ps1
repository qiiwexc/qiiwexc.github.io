BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'

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
        [Int]$script:TestPathCounter = 0
        [Int]$TestPathSuccessIteration = 0

        Mock Write-ActivityProgress {}
        Mock Test-Path {
            $script:TestPathCounter++
            return $script:TestPathCounter -ge $TestPathSuccessIteration
        }
        Mock Write-LogWarning {}
        Mock Test-NetworkConnection { return $True }
        Mock Initialize-AppDirectory {}
        Mock Start-BitsTransfer {}
        Mock Move-Item {}
        Mock Out-Success {}
    }

    It 'Should download file' {
        [Int]$TestPathSuccessIteration = 2

        Start-Download $TestUrl | Should -BeExactly $TestSavePath

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Test-Path -Exactly 2 -ParameterFilter { $Path -eq $TestSavePath }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1 -ParameterFilter {
            $Source -eq $TestUrl -and
            $Destination -eq $TestTempPath -and
            $Dynamic -eq $True
        }
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestTempPath -and
            $Destination -eq $TestSavePath -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download file with custom save path' {
        [Int]$TestPathSuccessIteration = 2

        Start-Download $TestUrl $TestSaveAs | Should -BeExactly $TestSavePathSaveAs

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Test-Path -Exactly 2 -ParameterFilter { $Path -eq $TestSavePathSaveAs }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1 -ParameterFilter {
            $Source -eq $TestUrl -and
            $Destination -eq $TestSavePathSaveAs -and
            $Dynamic -eq $True
        }
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestTempPathSaveAs -and
            $Destination -eq $TestSavePathSaveAs -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download file to temporary path' {
        [Int]$TestPathSuccessIteration = 2

        Start-Download $TestUrl -Temp | Should -BeExactly $TestSavePath

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Test-Path -Exactly 2 -ParameterFilter { $Path -eq $TestTempPath }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
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
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should throw if no network connection' {
        Mock Test-NetworkConnection { return $False }

        [Int]$TestPathSuccessIteration = 2

        { Start-Download $TestUrl } | Should -Throw 'No network connection detected'

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should throw if download fails' {
        [Int]$TestPathSuccessIteration = 3

        { Start-Download $TestUrl } | Should -Throw 'Possibly computer is offline or disk is full'

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
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
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        [Int]$TestPathSuccessIteration = 2

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        [Int]$TestPathSuccessIteration = 2

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Start-BitsTransfer failure' {
        Mock Start-BitsTransfer { throw $TestException }

        [Int]$TestPathSuccessIteration = 2

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Move-Item failure' {
        Mock Move-Item { throw $TestException }

        [Int]$TestPathSuccessIteration = 2

        { Start-Download $TestUrl } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 2
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-BitsTransfer -Exactly 1
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
