BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\Common\Open-InBrowser.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')

    Set-Variable -Option Constant TestReportPath ([String]"$PATH_APP_DIR\battery_report.html")
}

Describe 'Get-BatteryReport' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Initialize-AppDirectory {}
        Mock powercfg {}
        Mock Open-InBrowser {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should export and open battery report' {
        Get-BatteryReport

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke powercfg -Exactly 1
        Should -Invoke powercfg -Exactly 1 -ParameterFilter {
            $args[0] -eq '/BatteryReport' -and
            $args[1] -eq '/Output' -and
            $args[2] -eq $TestReportPath
        }
        Should -Invoke Open-InBrowser -Exactly 1
        Should -Invoke Open-InBrowser -Exactly 1 -ParameterFilter { $URL -eq $TestReportPath }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        Get-BatteryReport

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke powercfg -Exactly 0
        Should -Invoke Open-InBrowser -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle powercfg failure' {
        Mock powercfg { throw $TestException }

        Get-BatteryReport

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke powercfg -Exactly 1
        Should -Invoke Open-InBrowser -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Open-InBrowser failure' {
        Mock Open-InBrowser { throw $TestException }

        Get-BatteryReport

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke powercfg -Exactly 1
        Should -Invoke Open-InBrowser -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
