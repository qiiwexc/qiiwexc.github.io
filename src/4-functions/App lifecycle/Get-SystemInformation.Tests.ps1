BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestBaseBoardClassName ([String]'Win32_BaseBoard')
    Set-Variable -Option Constant TestBaseBoard ([CimInstance]::new($TestBaseBoardClassName))

    Set-Variable -Option Constant TestBiosElementClassName ([String]'CIM_BIOSElement')
    Set-Variable -Option Constant TestBiosElement ([CimInstance]::new($TestBiosElementClassName))

    Set-Variable -Option Constant TestDisplayVersion ([String]'TEST_DISPLAY_VERSION')
    Set-Variable -Option Constant TestWordRegPath ([String]'Registry::HKEY_CLASSES_ROOT\Word.Application\CurVer')
    Set-Variable -Option Constant TestWindowsNtPath ([String]'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion')

    Set-Variable -Option Constant OPERATING_SYSTEM (
        [Hashtable]@{
            Caption        = 'TEST_CAPTION'
            Version        = 'TEST_VERSION'
            OSArchitecture = 'TEST_ARCHITECTURE'
        }
    )

    Set-Variable -Option Constant SYSTEM_LANGUAGE ([String]'en-GB')
    Set-Variable -Option Constant PATH_OFFICE_C2R_CLIENT_EXE ([String]'C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe')
}

Describe 'Get-SystemInformation' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Get-CimInstance { return $TestBaseBoard } -ParameterFilter { $ClassName -eq $TestBaseBoardClassName }
        Mock Get-CimInstance { return $TestBiosElement } -ParameterFilter { $ClassName -eq $TestBiosElementClassName }
        Mock Get-ItemProperty { return @{ DisplayVersion = $TestDisplayVersion } } -ParameterFilter { $Path -eq $TestWindowsNtPath }
        Mock Get-ItemProperty { return @{ '(default)' = 'Word.Application.16' } } -ParameterFilter { $Path -eq $TestWordRegPath }
        Mock Test-Path { return $True } -ParameterFilter { $Path -eq $TestWordRegPath }
        Mock Test-Path { return $True } -ParameterFilter { $Path -eq $PATH_OFFICE_C2R_CLIENT_EXE }
    }

    It 'Should get system information with Office 2016/2019/2021/2024 C2R' {
        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter { $ClassName -eq $TestBaseBoardClassName }
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter { $ClassName -eq $TestBiosElementClassName }
        Should -Invoke Get-ItemProperty -Exactly 2
        Should -Invoke Test-Path -Exactly 2
    }

    It 'Should get system information with Office 2016/2019/2021/2024 MSI' {
        Mock Test-Path { return $False } -ParameterFilter { $Path -eq $PATH_OFFICE_C2R_CLIENT_EXE }

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 2
        Should -Invoke Test-Path -Exactly 2
    }

    It 'Should get system information for Office version 15 (2013)' {
        Mock Get-ItemProperty { return @{ '(default)' = 'Word.Application.15' } } -ParameterFilter { $Path -eq $TestWordRegPath }

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 2
    }

    It 'Should get system information for Office version 14 (2010)' {
        Mock Get-ItemProperty { return @{ '(default)' = 'Word.Application.14' } } -ParameterFilter { $Path -eq $TestWordRegPath }

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 2
    }

    It 'Should get system information for Office version 12 (2007)' {
        Mock Get-ItemProperty { return @{ '(default)' = 'Word.Application.12' } } -ParameterFilter { $Path -eq $TestWordRegPath }

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 2
    }

    It 'Should get system information for unknown Office version' {
        Mock Get-ItemProperty { return @{ '(default)' = 'Word.Application.99' } } -ParameterFilter { $Path -eq $TestWordRegPath }

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 2
    }

    It 'Should get system information when Office is not installed' {
        Mock Test-Path { return $False } -ParameterFilter { $Path -eq $TestWordRegPath }

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 9
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
        Should -Invoke Test-Path -Exactly 1
    }

    It 'Should handle Get-CimInstance failure for BaseBoard' {
        Mock Get-CimInstance { throw $TestException } -ParameterFilter { $ClassName -eq $TestBaseBoardClassName }

        { Get-SystemInformation } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-ItemProperty -Exactly 0
    }

    It 'Should handle Get-CimInstance failure for BIOSElement' {
        Mock Get-CimInstance { throw $TestException } -ParameterFilter { $ClassName -eq $TestBiosElementClassName }

        { Get-SystemInformation } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 0
    }

    It 'Should handle Get-ItemProperty failure for Windows version' {
        Mock Get-ItemProperty { throw $TestException } -ParameterFilter { $Path -eq $TestWindowsNtPath }

        { Get-SystemInformation } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 4
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
    }
}
