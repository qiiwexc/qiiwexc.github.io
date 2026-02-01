BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Set-LocalisationConfiguration' {
    BeforeEach {
        Mock Set-ItemProperty {}
        Mock Out-Failure {}
        Mock Set-WinHomeLocation {}
        Mock Get-WinUserLanguageList {
            $list = [Collections.Generic.List[PSObject]]::new()
            $list.Add(@{LanguageTag = 'en' })
            $list.Add(@{LanguageTag = 'ru' })
            return , $list
        }
        Mock Set-WinUserLanguageList {} -RemoveParameterType LanguageList
        Mock Out-Success {}
    }

    It 'Should apply Windows localisation configuration' {
        Set-LocalisationConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq 'HKCU:\Control Panel\International' -and
            $Name -eq 'sCurrency' -and
            $Value -eq ([Char]0x20AC)
        }
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Set-WinHomeLocation -Exactly 1 -ParameterFilter { $GeoId -eq 140 }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should skip setting Latvian language if already present' {
        Mock Get-WinUserLanguageList {
            $list = [Collections.Generic.List[PSObject]]::new()
            $list.Add(@{LanguageTag = 'lv' })
            return , $list
        }

        Set-LocalisationConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Set-ItemProperty failure' {
        Mock Set-ItemProperty { throw $TestException }

        Set-LocalisationConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Set-WinHomeLocation failure' {
        Mock Set-WinHomeLocation { throw $TestException }

        Set-LocalisationConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-WinUserLanguageList failure' {
        Mock Get-WinUserLanguageList { throw $TestException }

        Set-LocalisationConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-WinUserLanguageList failure' {
        Mock Set-WinUserLanguageList { throw $TestException }

        Set-LocalisationConfiguration

        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-WinHomeLocation -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Get-WinUserLanguageList -Exactly 1
        Should -Invoke Set-WinUserLanguageList -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
