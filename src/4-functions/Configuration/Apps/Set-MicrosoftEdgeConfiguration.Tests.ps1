BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Helpers\Update-JsonFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_EDGE_LOCAL_STATE ([String]'TEST_CONFIG_EDGE_LOCAL_STATE')
    Set-Variable -Option Constant CONFIG_EDGE_PREFERENCES ([String]'TEST_CONFIG_EDGE_PREFERENCES')

    Set-Variable -Option Constant TestProcessName ([String]'msedge')
    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
}

Describe 'Set-MicrosoftEdgeConfiguration' {
    BeforeEach {
        Mock Write-ActivityProgress {}
        Mock Update-JsonFile {}
    }

    It 'Should configure Microsoft Edge' {
        Set-MicrosoftEdgeConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Update-JsonFile -Exactly 2
        Should -Invoke Update-JsonFile -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $ProcessName -eq $TestProcessName -and
            $Content -eq $CONFIG_EDGE_LOCAL_STATE -and
            $Path -match '\\AppData\\Local\\Microsoft\\Edge\\User Data\\Local State$'
        }
        Should -Invoke Update-JsonFile -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $ProcessName -eq $TestProcessName -and
            $Content -eq $CONFIG_EDGE_PREFERENCES -and
            $Path -match '\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Preferences$'
        }
    }

    It 'Should handle Update-JsonFile failure' {
        Mock Update-JsonFile { throw $TestException }

        { Set-MicrosoftEdgeConfiguration $TestAppName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Update-JsonFile -Exactly 1
    }
}
