BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Initialize-AppDirectory.ps1"
    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\Get-RefusedRegistryKey.ps1"
    . "$PSScriptRoot\Invoke-RegistryImport.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestContent ([String[]]@("TEST_CONTENT1`n", 'TEST_CONTENT2'))

    Set-Variable -Option Constant TestRegFilePath ([String]"$PATH_APP_DIR\$TestAppName.reg")
    Set-Variable -Option Constant TestKeyFilePath ([String]"$PATH_APP_DIR\$TestAppName (one key).reg")
}

Describe 'Import-RegistryConfiguration' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Write-LogDebug {}
        Mock Initialize-AppDirectory {}
        Mock Set-Content {}
        Mock Invoke-RegistryImport { return 0 }
        Mock Get-RefusedRegistryKey {}
        Mock Write-LogWarning {}
        Mock Out-Success {}
    }

    It 'Should import registry configuration' {
        Import-RegistryConfiguration $TestAppName $TestContent

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestRegFilePath -and
            $Value -eq "Windows Registry Editor Version 5.00`n`nTEST_CONTENT1`nTEST_CONTENT2" -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-RegistryImport -Exactly 1
        Should -Invoke Invoke-RegistryImport -Exactly 1 -ParameterFilter { $Path -eq $TestRegFilePath }
        Should -Invoke Get-RefusedRegistryKey -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should name the keys that could not be written' {
        Mock Invoke-RegistryImport { return 1 }
        Mock Get-RefusedRegistryKey { return @('[KEY_A]', '[KEY_B]') }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw -ExpectedMessage 'Could not write ?KEY_A?, ?KEY_B?, every other key was written'

        Should -Invoke Get-RefusedRegistryKey -Exactly 1
        Should -Invoke Get-RefusedRegistryKey -Exactly 1 -ParameterFilter {
            $Content -eq "TEST_CONTENT1`nTEST_CONTENT2" -and
            $Path -eq $TestKeyFilePath
        }
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should succeed when every key is written on its own after a failed import' {
        Mock Invoke-RegistryImport { return 1 }

        Import-RegistryConfiguration $TestAppName $TestContent

        Should -Invoke Get-RefusedRegistryKey -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Invoke-RegistryImport -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-RegistryImport -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Invoke-RegistryImport failure' {
        Mock Invoke-RegistryImport { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Invoke-RegistryImport -Exactly 1
        Should -Invoke Get-RefusedRegistryKey -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-RefusedRegistryKey failure' {
        Mock Invoke-RegistryImport { return 1 }
        Mock Get-RefusedRegistryKey { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
