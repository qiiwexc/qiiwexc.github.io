BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\Configuration\Helpers\Update-BrowserConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_EDGE_LOCAL_STATE ([String]'TEST_CONFIG_EDGE_LOCAL_STATE')
    Set-Variable -Option Constant CONFIG_EDGE_PREFERENCES ([String]'TEST_CONFIG_EDGE_PREFERENCES')

    Set-Variable -Option Constant TestProcessName ([String]'msedge')
    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
}

Describe 'Set-MicrosoftEdgeConfiguration' {
    BeforeEach {
        Mock Update-BrowserConfiguration {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should configure Microsoft Edge' {
        Set-MicrosoftEdgeConfiguration $TestAppName

        Should -Invoke Update-BrowserConfiguration -Exactly 2
        Should -Invoke Update-BrowserConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $ProcessName -eq $TestProcessName -and
            $Content -eq $CONFIG_EDGE_LOCAL_STATE -and
            $Path -match '\\AppData\\Local\\Microsoft\\Edge\\User Data\\Local State$'
        }
        Should -Invoke Update-BrowserConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $ProcessName -eq $TestProcessName -and
            $Content -eq $CONFIG_EDGE_PREFERENCES -and
            $Path -match '\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Preferences$'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Update-BrowserConfiguration failure' {
        Mock Update-BrowserConfiguration { throw $TestException }

        Set-MicrosoftEdgeConfiguration $TestAppName

        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
