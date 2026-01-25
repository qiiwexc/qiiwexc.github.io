BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-SysPrepConfig' {
    It 'Should replace HKEY_CURRENT_USER with HKEY_USERS\.DEFAULT' {
        Get-SysPrepConfig "[HKEY_CURRENT_USER\Test]`nTEST_CONFIG" | Should -BeExactly "[HKEY_USERS\.DEFAULT\Test]`nTEST_CONFIG"
    }
}
