BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestBaseBoardClassName ([String]'Win32_BaseBoard')
    Set-Variable -Option Constant TestBaseBoard ([CimInstance]::new($TestBaseBoardClassName))

    Set-Variable -Option Constant TestBiosElementClassName ([String]'CIM_BIOSElement')
    Set-Variable -Option Constant TestBiosElement ([CimInstance]::new($TestBiosElementClassName))

    Set-Variable -Option Constant TestDisplayVersion ([String]'TEST_DISPLAY_VERSION')

    Set-Variable -Option Constant OPERATING_SYSTEM (
        [Hashtable]@{
            Caption        = 'TEST_CAPTION'
            Version        = 'TEST_VERSION'
            OSArchitecture = 'TEST_ARCHITECTURE'
        }
    )
}

Describe 'Get-SystemInformation' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Get-CimInstance { return $TestBaseBoard } -ParameterFilter { $ClassName -eq $TestBaseBoardClassName }
        Mock Get-CimInstance { return $TestBiosElement } -ParameterFilter { $ClassName -eq $TestBiosElementClassName }
        Mock Get-ItemProperty { return $TestDisplayVersion }

        [Int]$OFFICE_VERSION = 16
        [String]$OFFICE_INSTALL_TYPE = 'C2R'
    }

    It 'Should get system information' {
        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter { $ClassName -eq $TestBaseBoardClassName }
        Should -Invoke Get-CimInstance -Exactly 1 -ParameterFilter { $ClassName -eq $TestBiosElementClassName }
        Should -Invoke Get-ItemProperty -Exactly 1
    }

    It 'Should get system information for Office version 15' {
        [Int]$OFFICE_VERSION = 15

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
    }

    It 'Should get system information for Office version 14' {
        [Int]$OFFICE_VERSION = 14

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
    }

    It 'Should get system information for Office version 13' {
        [Int]$OFFICE_VERSION = 13

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
    }

    It 'Should get system information for Office version 12' {
        [Int]$OFFICE_VERSION = 12

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 10
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
    }

    It 'Should get system information for unknown Office version' {
        [String]$OFFICE_INSTALL_TYPE = $Null

        Get-SystemInformation

        Should -Invoke Write-LogInfo -Exactly 9
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
    }

    It 'Should handle Get-CimInstance failure' {
        Mock Get-CimInstance { throw $TestException } -ParameterFilter { $ClassName -eq $TestBaseBoardClassName }

        { Get-SystemInformation } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Get-CimInstance -Exactly 1
        Should -Invoke Get-ItemProperty -Exactly 0
    }

    It 'Should handle Get-CimInstance failure' {
        Mock Get-CimInstance { throw $TestException } -ParameterFilter { $ClassName -eq $TestBiosElementClassName }

        { Get-SystemInformation } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 2
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 0
    }

    It 'Should handle Get-ItemProperty failure' {
        Mock Get-ItemProperty { throw $TestException }

        { Get-SystemInformation } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 4
        Should -Invoke Get-CimInstance -Exactly 2
        Should -Invoke Get-ItemProperty -Exactly 1
    }
}
