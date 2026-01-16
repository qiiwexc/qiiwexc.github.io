BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\Start-DownloadUnzipAndRun.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_OOSHUTUP10 ([String]'TEST_PATH_OOSHUTUP10')
    Set-Variable -Option Constant PATH_WORKING_DIR ([String]'TEST_PATH_WORKING_DIR')
    Set-Variable -Option Constant CONFIG_OOSHUTUP10 ([String]'TEST_CONFIG_OOSHUTUP10')

    Set-Variable -Option Constant TestDownloadUrl ([String]'{URL_OOSHUTUP10}')
    Set-Variable -Option Constant TestConfigFileName ([String]'ooshutup10.cfg')
}

Describe 'Start-OoShutUp10' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Test-NetworkConnection { return $True }
        Mock New-Item {}
        Mock Set-Content {}
        Mock Start-DownloadUnzipAndRun {}
        Mock Write-LogWarning {}
        Mock Out-Success {}

        [Bool]$TestExecute = $False
        [Bool]$TestSilent = $False
    }

    It 'Should download OoShutUp10' {
        Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $PATH_WORKING_DIR -and
            $ItemType -eq 'Directory' -and
            $Force -eq $True
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$PATH_WORKING_DIR\$TestConfigFileName" -and
            $Value -eq $CONFIG_OOSHUTUP10 -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestDownloadUrl -and
            $Execute -eq $TestExecute -and
            $Params -eq $Null
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download OoShutUp10 and run' {
        [Bool]$TestExecute = $True

        Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter {
            $Path -eq $PATH_OOSHUTUP10 -and
            $ItemType -eq 'Directory' -and
            $Force -eq $True
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$PATH_OOSHUTUP10\$TestConfigFileName" -and
            $Value -eq $CONFIG_OOSHUTUP10 -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestDownloadUrl -and
            $Execute -eq $TestExecute -and
            $Params -eq $Null
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download OoShutUp10 and run silently' {
        [Bool]$TestExecute = $True
        [Bool]$TestSilent = $True

        Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestDownloadUrl -and
            $Execute -eq $TestExecute -and
            $Params -eq "$PATH_OOSHUTUP10\$TestConfigFileName"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        { Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        { Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent } | Should -Not -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Start-OoShutUp10 -Execute:$TestExecute -Silent:$TestSilent } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
