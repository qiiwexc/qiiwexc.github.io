BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestExecutableName ([String]'TEST_APP.exe')
    Set-Variable -Option Constant TestUserKey ([String]"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$TestExecutableName")
    Set-Variable -Option Constant TestMachineKey ([String]"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$TestExecutableName")
    Set-Variable -Option Constant TestUserPath ([String]'C:\Users\TEST\AppData\Local\TEST_APP\TEST_APP.exe')
    Set-Variable -Option Constant TestMachinePath ([String]'C:\Program Files\TEST_APP\TEST_APP.exe')

    # A registry key as far as the function reads it: its default value
    function New-TestKey([String]$DefaultValue) {
        return [PSCustomObject]@{ DefaultValue = $DefaultValue } | Add-Member -MemberType ScriptMethod -Name GetValue -Value { param([String]$ValueName) $this.DefaultValue } -PassThru
    }
}

Describe 'Get-AppExecutablePath' {
    BeforeAll {
        Mock Test-Path { return $True }
        # Some installers write the path in quotes
        Mock Get-Item { return New-TestKey "`"$TestUserPath`"" } -ParameterFilter { $LiteralPath -eq $TestUserKey }
        Mock Get-Item { return New-TestKey $TestMachinePath } -ParameterFilter { $LiteralPath -eq $TestMachineKey }
    }

    It 'Should prefer a per-user installation, without its quotes' {
        Get-AppExecutablePath $TestExecutableName | Should -BeExactly $TestUserPath

        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $LiteralPath -eq $TestUserPath -and $PathType -eq 'Leaf' }
    }

    It 'Should fall back to a machine-wide installation' {
        Mock Test-Path { return $LiteralPath -ne $TestUserKey }

        Get-AppExecutablePath $TestExecutableName | Should -BeExactly $TestMachinePath

        Should -Invoke Get-Item -Exactly 1
        Should -Invoke Get-Item -Exactly 1 -ParameterFilter { $LiteralPath -eq $TestMachineKey }
    }

    It 'Should skip an entry whose file is gone' {
        Mock Test-Path { return $LiteralPath -ne $TestUserPath }

        Get-AppExecutablePath $TestExecutableName | Should -BeExactly $TestMachinePath

        Should -Invoke Get-Item -Exactly 2
    }

    It 'Should skip an entry without a default value' {
        Mock Get-Item { return New-TestKey '' } -ParameterFilter { $LiteralPath -eq $TestUserKey }

        Get-AppExecutablePath $TestExecutableName | Should -BeExactly $TestMachinePath
    }

    It 'Should return an empty string when the app is not installed' {
        Mock Test-Path { return $False }

        Get-AppExecutablePath $TestExecutableName | Should -BeExactly ''

        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-Item -Exactly 0
    }

    It 'Should let a failure to read the registry reach the caller' {
        Mock Get-Item { throw $TestException } -ParameterFilter { $LiteralPath -eq $TestUserKey }

        { Get-AppExecutablePath $TestExecutableName } | Should -Throw $TestException
    }
}
