BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\..\Common\Network.ps1"
    . "$PSScriptRoot\..\..\..\Common\New-Directory.ps1"
    . "$PSScriptRoot\..\..\..\Common\Start-DownloadUnzipAndRun.ps1"
    . "$PSScriptRoot\Assertions.ps1"
    . "$PSScriptRoot\..\..\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_OOSHUTUP10 ([String]'TEST_PATH_OOSHUTUP10')
    Set-Variable -Option Constant PATH_WORKING_DIR ([String]'TEST_PATH_WORKING_DIR')
    # LF line endings and a non-ASCII character, as a checkout can embed the file
    Set-Variable -Option Constant CONFIG_OOSHUTUP10 ([String]"TEST_LINE_1`nTEST_LINE_2 $([Char]0xA9)`n")
    Set-Variable -Option Constant TestConfigBytes ([Byte[]](0x54, 0x45, 0x53, 0x54, 0x5F, 0x4C, 0x49, 0x4E, 0x45, 0x5F, 0x31, 0x0D, 0x0A, 0x54, 0x45, 0x53, 0x54, 0x5F, 0x4C, 0x49, 0x4E, 0x45, 0x5F, 0x32, 0x20, 0xC2, 0xA9, 0x0D, 0x0A))

    Set-Variable -Option Constant TestDownloadUrl ([String]'{URL_OOSHUTUP10}')
    Set-Variable -Option Constant TestConfigFileName ([String]'ooshutup10.cfg')
}

Describe 'Start-OoShutUp10' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Test-WindowsDebloatIsRunning {}
        Mock New-Directory {}
        Mock Set-Content {}
        Mock Start-DownloadUnzipAndRun {}
        Mock Write-LogWarning {}
    }

    It 'Should download OoShutUp10' {
        Start-OoShutUp10

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $PATH_WORKING_DIR }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$PATH_WORKING_DIR\$TestConfigFileName" -and
            $Encoding -eq 'Byte' -and
            ($Value -join ',') -eq ($TestConfigBytes -join ',')
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestDownloadUrl -and
            $Execute -eq $False -and
            $Params -eq ''
        }
    }

    It 'Should download OoShutUp10 and run' {
        Start-OoShutUp10 -Execute

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $PATH_OOSHUTUP10 }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$PATH_OOSHUTUP10\$TestConfigFileName" -and
            $Encoding -eq 'Byte' -and
            ($Value -join ',') -eq ($TestConfigBytes -join ',')
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestDownloadUrl -and
            $Execute -eq $True -and
            $Params -eq ''
        }
    }

    It 'Should download OoShutUp10 and run silently' {
        Start-OoShutUp10 -Execute -Silent

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestDownloadUrl -and
            $Execute -eq $True -and
            $Params -eq "$PATH_OOSHUTUP10\$TestConfigFileName"
        }
    }

    It 'Should exit if Windows debloat is running' {
        Mock Test-WindowsDebloatIsRunning { return @(@{ ProcessName = 'powershell' }) }

        Start-OoShutUp10

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 2
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
    }

    It 'Should handle Test-WindowsDebloatIsRunning failure' {
        Mock Test-WindowsDebloatIsRunning { throw $TestException }

        { Start-OoShutUp10 } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        Start-OoShutUp10

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        Start-OoShutUp10

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Start-OoShutUp10 } | Should -Throw $TestException

        Should -Invoke Test-WindowsDebloatIsRunning -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }
}
