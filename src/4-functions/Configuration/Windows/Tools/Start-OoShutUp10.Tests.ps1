BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\New-Directory.ps1'
    . '.\src\4-functions\Common\Start-DownloadUnzipAndRun.ps1'
    . '.\src\4-functions\Configuration\Windows\Tools\Assertions.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

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
        Mock Assert-WindowsDebloatIsRunning {}
        Mock New-Directory {}
        Mock Set-Content {}
        Mock Start-DownloadUnzipAndRun {}
        Mock Write-LogWarning {}
        Mock Out-Success {}
    }

    It 'Should download OoShutUp10' {
        Start-OoShutUp10

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $PATH_WORKING_DIR }
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
            $Execute -eq $False -and
            $Params -eq ''
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download OoShutUp10 and run' {
        Start-OoShutUp10 -Execute

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $PATH_OOSHUTUP10 }
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
            $Execute -eq $True -and
            $Params -eq ''
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should download OoShutUp10 and run silently' {
        Start-OoShutUp10 -Execute -Silent

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestDownloadUrl -and
            $Execute -eq $True -and
            $Params -eq "$PATH_OOSHUTUP10\$TestConfigFileName"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should exit if Windows debloat is running' {
        Mock Assert-WindowsDebloatIsRunning { return @(@{ ProcessName = 'powershell' }) }

        Start-OoShutUp10

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Assert-WindowsDebloatIsRunning failure' {
        Mock Assert-WindowsDebloatIsRunning { throw $TestException }

        { Start-OoShutUp10 } | Should -Throw $TestException

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        Start-OoShutUp10

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        Start-OoShutUp10

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Start-OoShutUp10 } | Should -Throw $TestException

        Should -Invoke Assert-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
