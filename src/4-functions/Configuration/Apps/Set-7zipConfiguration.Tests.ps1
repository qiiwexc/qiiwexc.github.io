BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Progressbar.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_7ZIP ([String]"TEST_CONFIG_7ZIP1`n[HKEY_CURRENT_USER\Test]`nTEST_CONFIG_7ZIP2")

    Set-Variable -Option Constant TestAppName ([String]'TEST_APP_NAME')
    Set-Variable -Option Constant TestConfig ([String]"TEST_CONFIG_7ZIP1`n[HKEY_USERS\.DEFAULT\Test]`nTEST_CONFIG_7ZIP2`nTEST_CONFIG_7ZIP1`n[HKEY_CURRENT_USER\Test]`nTEST_CONFIG_7ZIP2")
}

Describe 'Set-7zipConfiguration' {
    BeforeEach {
        Mock Write-ActivityProgress {}
        Mock Import-RegistryConfiguration {}
        Mock Write-LogError {}
    }

    It 'Should configure 7zip' {
        Set-7zipConfiguration $TestAppName

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq $TestAppName -and
            $Content -match 'TEST_CONFIG_7ZIP1\n\[HKEY_USERS\\\.DEFAULT\\Test\]\nTEST_CONFIG_7ZIP2' -and
            $Content -match 'TEST_CONFIG_7ZIP1\n\[HKEY_CURRENT_USER\\Test\]\nTEST_CONFIG_7ZIP2'
        }
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        Mock Import-RegistryConfiguration { throw $TestException }

        { Set-7zipConfiguration $TestAppName } | Should -Not -Throw

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Write-LogError -Exactly 1
    }
}
