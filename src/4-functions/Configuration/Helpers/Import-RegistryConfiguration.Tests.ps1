BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Initialize-AppDirectory.ps1"
    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\Add-SysPrepConfig.ps1"
    . "$PSScriptRoot\Dismount-DefaultUserHive.ps1"
    . "$PSScriptRoot\Get-RefusedRegistryKey.ps1"
    . "$PSScriptRoot\Invoke-RegistryImport.ps1"
    . "$PSScriptRoot\Mount-DefaultUserHive.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestContent ([String[]]@("TEST_CONTENT1`n", 'TEST_CONTENT2'))

    Set-Variable -Option Constant TestMachineSection ([String]"[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]`n`"TEST_VALUE`"=dword:00000001`n`n")
    Set-Variable -Option Constant TestUserSection ([String]"[HKEY_CURRENT_USER\TEST_USER_KEY]`n`"TEST_VALUE`"=dword:00000001`n")
    Set-Variable -Option Constant TestNewUsersContent ([String[]]@((Add-SysPrepConfig "$TestMachineSection$TestUserSection"), "`n[HKEY_CURRENT_USER\TEST_ADDED_KEY]`n"))

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
        Mock Mount-DefaultUserHive { return $True }
        Mock Dismount-DefaultUserHive {}
    }

    It 'Should import registry configuration' {
        Import-RegistryConfiguration $TestAppName $TestContent

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestRegFilePath -and
            $Value -eq "Windows Registry Editor Version 5.00`n`nTEST_CONTENT1`nTEST_CONTENT2" -and
            $Encoding -eq 'Unicode' -and
            $NoNewline -eq $True
        }
        Should -Invoke Invoke-RegistryImport -Exactly 1
        Should -Invoke Invoke-RegistryImport -Exactly 1 -ParameterFilter { $Path -eq $TestRegFilePath }
        Should -Invoke Get-RefusedRegistryKey -Exactly 0
        Should -Invoke Mount-DefaultUserHive -Exactly 0
        Should -Invoke Dismount-DefaultUserHive -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should load the default user profile for the keys copied for new accounts, and unload it after' {
        Import-RegistryConfiguration $TestAppName $TestNewUsersContent

        Should -Invoke Mount-DefaultUserHive -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            [String]$Text = -join $Value
            $Text.Contains('[HKEY_USERS\DefaultUser\TEST_USER_KEY]') -and
            $Text.Contains('[HKEY_CURRENT_USER\TEST_USER_KEY]') -and
            $Text.Contains('[HKEY_CURRENT_USER\TEST_ADDED_KEY]') -and
            -not $Text.Contains('[HKEY_USERS\DefaultUser\TEST_ADDED_KEY]')
        }
        Should -Invoke Invoke-RegistryImport -Exactly 1
        Should -Invoke Dismount-DefaultUserHive -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should leave out the keys for new accounts and import the rest when the default user profile cannot be loaded' {
        Mock Mount-DefaultUserHive { return $False }

        Import-RegistryConfiguration $TestAppName $TestNewUsersContent

        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            (-join $Value) -eq "Windows Registry Editor Version 5.00`n`n$TestMachineSection$TestUserSection`n[HKEY_CURRENT_USER\TEST_ADDED_KEY]`n"
        }
        Should -Invoke Invoke-RegistryImport -Exactly 1
        Should -Invoke Dismount-DefaultUserHive -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should unload the default user profile when the import fails' {
        Mock Invoke-RegistryImport { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestNewUsersContent } | Should -Throw $TestException

        Should -Invoke Dismount-DefaultUserHive -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should name refused keys with the default user profile still loaded' {
        Mock Invoke-RegistryImport { return 1 }
        Mock Get-RefusedRegistryKey { return @('[HKEY_USERS\DefaultUser\TEST_USER_KEY]') }

        { Import-RegistryConfiguration $TestAppName $TestNewUsersContent } | Should -Throw -ExpectedMessage '*DefaultUser*'

        Should -Invoke Get-RefusedRegistryKey -Exactly 1 -ParameterFilter { $Content.Contains('[HKEY_USERS\DefaultUser\TEST_USER_KEY]') }
        Should -Invoke Dismount-DefaultUserHive -Exactly 1
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
        Should -Invoke Write-LogWarning -Exactly 0
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
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Invoke-RegistryImport -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Invoke-RegistryImport failure' {
        Mock Invoke-RegistryImport { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Invoke-RegistryImport -Exactly 1
        Should -Invoke Get-RefusedRegistryKey -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-RefusedRegistryKey failure' {
        Mock Invoke-RegistryImport { return 1 }
        Mock Get-RefusedRegistryKey { throw $TestException }

        { Import-RegistryConfiguration $TestAppName $TestContent } | Should -Throw $TestException

        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }
}
