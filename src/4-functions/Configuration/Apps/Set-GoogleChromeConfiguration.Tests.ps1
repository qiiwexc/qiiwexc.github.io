BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\Helpers\Get-AppExecutablePath.ps1"
    . "$PSScriptRoot\..\Helpers\Update-BrowserConfiguration.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_CHROME_LOCAL_STATE ([String]'TEST_CONFIG_CHROME_LOCAL_STATE')
    Set-Variable -Option Constant CONFIG_CHROME_PREFERENCES ([String]'TEST_CONFIG_CHROME_PREFERENCES')

    Set-Variable -Option Constant TestProcessName ([String]'chrome')
    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
}

Describe 'Set-GoogleChromeConfiguration' {
    BeforeAll {
        Mock Get-AppExecutablePath { return 'C:\TEST_DIR\chrome.exe' }
        Mock Write-LogWarning {}
        Mock Update-BrowserConfiguration {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should configure Google Chrome' {
        Set-GoogleChromeConfiguration $TestAppName

        Should -Invoke Get-AppExecutablePath -Exactly 1
        Should -Invoke Get-AppExecutablePath -Exactly 1 -ParameterFilter { $ExecutableName -eq "$TestProcessName.exe" }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Update-BrowserConfiguration -Exactly 2
        Should -Invoke Update-BrowserConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $ProcessName -eq $TestProcessName -and
            $Content -eq $CONFIG_CHROME_LOCAL_STATE -and
            $Path -match '\\AppData\\Local\\Google\\Chrome\\User Data\\Local State$'
        }
        Should -Invoke Update-BrowserConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $ProcessName -eq $TestProcessName -and
            $Content -eq $CONFIG_CHROME_PREFERENCES -and
            $Path -match '\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\Preferences$'
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should skip the browser when it is not installed' {
        Mock Get-AppExecutablePath { return '' }

        Set-GoogleChromeConfiguration $TestAppName

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter { $Message -like "*'$TestAppName' is not installed*" }
        Should -Invoke Update-BrowserConfiguration -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should report a failed update once, and not go on to report the browser done' {
        Mock Update-BrowserConfiguration { throw $TestException }

        Set-GoogleChromeConfiguration $TestAppName

        Should -Invoke Update-BrowserConfiguration -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -eq "Failed to configure '$TestAppName': $TestException" }
    }
}