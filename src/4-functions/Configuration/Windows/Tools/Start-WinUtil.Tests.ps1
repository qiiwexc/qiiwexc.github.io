BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\..\Common\Invoke-CustomCommand.ps1"
    . "$PSScriptRoot\..\..\..\Common\Start-Download.ps1"
    . "$PSScriptRoot\..\..\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestScriptPath ([String]'C:\Users\TEST_USER\AppData\Local\Temp\qiiwexc\winutil.ps1')
    Set-Variable -Option Constant TestCommand ([String]"& ([ScriptBlock]::Create((Get-Content -Raw -Encoding UTF8 -LiteralPath '$TestScriptPath')))")
}

Describe 'Start-WinUtil' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Start-Download { return $TestScriptPath }
        Mock Invoke-CustomCommand {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should run the pinned release after checking its checksum' {
        Start-WinUtil

        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Start-Download -Exactly 1 -ParameterFilter {
            $URL -eq '{URL_WINUTIL}' -and
            $Sha256 -eq '{SHA256_WINUTIL}' -and
            $Temp -eq $True
        }
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -eq $TestCommand }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should escape a quote in the download path' {
        Mock Start-Download { return "C:\Users\O'Brien\qiiwexc\winutil.ps1" }

        Start-WinUtil

        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -like "*-LiteralPath 'C:\Users\O''Brien\qiiwexc\winutil.ps1')))" }
    }

    It 'Should not run anything if the download fails' {
        Mock Start-Download { throw $TestException }

        Start-WinUtil

        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        Start-WinUtil

        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
