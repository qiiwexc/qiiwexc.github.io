BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Helpers\Write-ConfigurationFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_VLC ([String]'TEST_CONFIG_VLC')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
}

Describe 'Set-VlcConfiguration' {
    BeforeEach {
        Mock Write-ActivityProgress {}
        Mock Write-ConfigurationFile {}
        Mock Write-LogError {}
    }

    It 'Should configure VLC' {
        Set-VlcConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $Content -eq $CONFIG_VLC -and
            $Path -match '\\AppData\\Roaming\\vlc\\vlcrc$'
        }
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should handle Write-ConfigurationFile failure' {
        Mock Write-ConfigurationFile { throw $TestException }

        { Set-VlcConfiguration $TestAppName } | Should -Not -Throw

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Write-ConfigurationFile -Exactly 1
        Should -Invoke Write-LogError -Exactly 1
    }
}
