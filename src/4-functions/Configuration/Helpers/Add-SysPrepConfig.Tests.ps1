BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Add-SysPrepConfig' {
    It 'Should copy the per-user keys into the default user profile' {
        Add-SysPrepConfig "[HKEY_CURRENT_USER\Test]`nTEST_CONFIG" | Should -BeExactly "[HKEY_USERS\DefaultUser\Test]`nTEST_CONFIG`n[HKEY_CURRENT_USER\Test]`nTEST_CONFIG"
    }

    It 'Should copy only the per-user keys, deletions included, and leave the machine keys to be written once' {
        Set-Variable -Option Constant Config ([String]("[HKEY_CURRENT_USER\User1]`n`"A`"=dword:00000001`n`n" +
                "[HKEY_LOCAL_MACHINE\Machine]`n`"B`"=dword:00000001`n`n" +
                "[-HKEY_CURRENT_USER\User2]`n`n" +
                "[HKEY_CURRENT_USER\User3]`n`"C`"=-`n"))

        Add-SysPrepConfig $Config | Should -BeExactly ("[HKEY_USERS\DefaultUser\User1]`n`"A`"=dword:00000001`n`n" +
            "[-HKEY_USERS\DefaultUser\User2]`n`n" +
            "[HKEY_USERS\DefaultUser\User3]`n`"C`"=-`n`n" +
            $Config)
    }

    It 'Should return a config without per-user keys as it is' {
        Add-SysPrepConfig "[HKEY_LOCAL_MACHINE\Test]`nTEST_CONFIG" | Should -BeExactly "[HKEY_LOCAL_MACHINE\Test]`nTEST_CONFIG"
    }
}
