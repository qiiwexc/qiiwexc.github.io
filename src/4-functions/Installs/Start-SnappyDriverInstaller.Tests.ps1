BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\Common\Start-DownloadUnzipAndRun.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_SDI ([String]'TEST_CONFIG_SDI')
    Set-Variable -Option Constant TestSdiUrl ([String]'{URL_SDI}')
}

Describe 'Start-SnappyDriverInstaller' {
    BeforeAll {
        Mock Write-LogInfo {}
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

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Start-SnappyDriverInstaller -Execute } | Should -Throw $TestException

        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }
}
