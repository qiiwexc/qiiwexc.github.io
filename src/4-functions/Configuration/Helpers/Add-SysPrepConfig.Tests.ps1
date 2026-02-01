BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Add-SysPrepConfig' {
    It 'Should replace add SysPrep config' {
        Add-SysPrepConfig "[HKEY_CURRENT_USER\Test]`nTEST_CONFIG" | Should -BeExactly "[HKEY_USERS\.DEFAULT\Test]`nTEST_CONFIG`n[HKEY_CURRENT_USER\Test]`nTEST_CONFIG"
    }
}
