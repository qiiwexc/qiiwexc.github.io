BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\Common\Start-DownloadUnzipAndRun.ps1"
    . "$PSScriptRoot\..\Configuration\Windows\Tools\Assertions.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_SDI ([String]'TEST_CONFIG_SDI')
    Set-Variable -Option Constant TestSdiUrl ([String]'{URL_SDI}')
}

Describe 'Start-SnappyDriverInstaller' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Write-LogWarning {}
        Mock Test-SdiIsRunning {}
        Mock Start-DownloadUnzipAndRun {}
    }

    It 'Should download Snappy Driver Installer' {
        Start-SnappyDriverInstaller

        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestSdiUrl -and
            $Execute -eq $False -and
            $ConfigFile -eq 'sdi.cfg' -and
            $Configuration -eq $CONFIG_SDI
        }
    }

    It 'Should download and start Snappy Driver Installer' {
        Start-SnappyDriverInstaller -Execute

        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestSdiUrl -and
            $Execute -eq $True -and
            $ConfigFile -eq 'sdi.cfg' -and
            $Configuration -eq $CONFIG_SDI
        }
    }

    It 'Should not start Snappy Driver Installer again while it is running' {
        Mock Test-SdiIsRunning { return @(@{ ProcessName = 'SDI64-drv' }) }

        Start-SnappyDriverInstaller -Execute

        Should -Invoke Test-SdiIsRunning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
    }

    It 'Should download it while it is running, when not asked to start it' {
        Mock Test-SdiIsRunning { return @(@{ ProcessName = 'SDI64-drv' }) }

        Start-SnappyDriverInstaller

        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Start-SnappyDriverInstaller -Execute } | Should -Throw $TestException

        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }
}
