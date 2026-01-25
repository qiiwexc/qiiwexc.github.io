BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestContent ([String[]]@("TEST_CONTENT1`n", 'TEST_CONTENT2'))

    Set-Variable -Option Constant TestRegFilePath ([String]"$PATH_APP_DIR\$TestAppName.reg")
}

Describe 'Import-RegistryConfiguration' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Initialize-AppDirectory {}
        Mock Set-Content {}
        Mock Start-Process {}
        Mock Write-LogWarning {}
        Mock Out-Success {}
        Mock Split-Path {}
    }

    It 'Should import registry configuration' {
        Import-RegistryConfiguration $TestAppName $TestContent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestRegFilePath -and
            $Value -eq "Windows Registry Editor Version 5.00`n`nTEST_CONTENT1`nTEST_CONTENT2" -and
            $NoNewline -eq $True
        }
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq 'regedit' -and
            $ArgumentList -eq "/s `"$TestRegFilePath`"" -and
            $Verb -eq 'RunAs' -and
            $Wait -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
