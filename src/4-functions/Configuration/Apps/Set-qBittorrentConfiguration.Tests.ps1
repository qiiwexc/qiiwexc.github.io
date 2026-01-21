BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Helpers\Write-ConfigurationFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_QBITTORRENT_BASE ([String]'TEST_CONFIG_QBITTORRENT_BASE')
    Set-Variable -Option Constant CONFIG_QBITTORRENT_RUSSIAN ([String]'TEST_CONFIG_QBITTORRENT_RUSSIAN')
    Set-Variable -Option Constant CONFIG_QBITTORRENT_ENGLISH ([String]'TEST_CONFIG_QBITTORRENT_ENGLISH')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestConfigPath ([String]"\\AppData\\Roaming\\$TestAppName\\$TestAppName.ini$")
}

Describe 'Set-qBittorrentConfiguration' {
    BeforeEach {
        [String]$SYSTEM_LANGUAGE = 'en-GB'

        Mock Write-ActivityProgress {}
        Mock Write-ConfigurationFile {}
        Mock Out-Failure {}
    }

    It 'Should configure qBittorrent (English)' {
        Set-qBittorrentConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $Content -eq ($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_ENGLISH) -and
            $Path -match $TestConfigPath
        }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should configure qBittorrent (Russian)' {
        [String]$SYSTEM_LANGUAGE = 'ru-RU'

        Set-qBittorrentConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $Content -eq ($CONFIG_QBITTORRENT_BASE + $CONFIG_QBITTORRENT_RUSSIAN) -and
            $Path -match $TestConfigPath
        }
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Write-ConfigurationFile failure' {
        Mock Write-ConfigurationFile { throw $TestException }

        Set-qBittorrentConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
    }
}
