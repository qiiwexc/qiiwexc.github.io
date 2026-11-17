BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\Helpers\Add-SysPrepConfig.ps1"
    . "$PSScriptRoot\..\Helpers\Import-RegistryConfiguration.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant CONFIG_SECURITY ([String]"[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]`n`"TEST_VALUE`"=dword:00000001`n`n[HKEY_CURRENT_USER\TEST_USER_KEY]`n`"TEST_VALUE`"=dword:00000001`n")

    Set-Variable -Option Constant TestLsaLock ([String]"[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA]`n`"RunAsPPL`"=dword:00000001`n")
}

Describe 'Set-SecurityConfiguration' {
    BeforeAll {
        Mock Import-RegistryConfiguration {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    BeforeEach {
        [PSObject]$OPERATING_SYSTEM = [PSCustomObject]@{ Version = '10.0.26100' }
    }

    It 'Should import the security configuration for the machine, the current user and the default user' {
        Set-SecurityConfiguration

        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            [String]$Keys = -join $Content
            $AppName -eq 'Windows Security Config' -and
            $Keys.Contains('[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]') -and
            $Keys.Contains('[HKEY_CURRENT_USER\TEST_USER_KEY]') -and
            $Keys.Contains('[HKEY_USERS\DefaultUser\TEST_USER_KEY]') -and
            -not $Keys.Contains('RunAsPPL')
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should turn LSA protection on with its UEFI lock on Windows <Name>, which reads no other value' -ForEach @(
        @{ Name = '10 22H2'; Version = '10.0.19045' }
        @{ Name = '11 21H2'; Version = '10.0.22000' }
    ) {
        [PSObject]$OPERATING_SYSTEM = [PSCustomObject]@{ Version = $Version }

        Set-SecurityConfiguration

        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            [String]$Keys = -join $Content
            $Keys.Contains('[HKEY_LOCAL_MACHINE\TEST_MACHINE_KEY]') -and
            $Keys.EndsWith("`n$TestLsaLock")
        }
    }

    It 'Should leave LSA protection without its UEFI lock on Windows 11 22H2' {
        [PSObject]$OPERATING_SYSTEM = [PSCustomObject]@{ Version = '10.0.22621' }

        Set-SecurityConfiguration

        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter { -not (-join $Content).Contains('RunAsPPL') }
    }

    It 'Should report a failed import' {
        Mock Import-RegistryConfiguration { throw $TestException }

        Set-SecurityConfiguration

        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1 -ParameterFilter { $Message -match $TestException }
    }
}
