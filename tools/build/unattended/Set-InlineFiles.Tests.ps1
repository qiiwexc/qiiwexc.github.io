BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant LocaleEnglish ([String]'English')
    Set-Variable -Option Constant LocaleRussian ([String]'Russian')

    Set-Variable -Option Constant TestConfigsPath ([String]'TEST_SOURCE_PATH')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{CONFIG_APP_ASSOCIATIONS}`n{CONFIG_QBITTORRENT_LOCALIZED}`n{CONFIG_WINDOWS_HKEY_LOCAL_MACHINE}`n{CONFIG_WINDOWS_LOCALISED}`nTEST_TEMPLATE_CONTENT_2")

    Set-Variable -Option Constant TestRegFileContent ([String]"TEST_REG_FILE_CONTENT_1`n[HKEY_CURRENT_USER\Test]`n`"TestValue`"=1`nTEST_REG_FILE_CONTENT_2 ")
    Set-Variable -Option Constant TestGenericFileContent ([String]"TEST_GENERIC_FILE_CONTENT_1`nTEST_GENERIC_FILE_CONTENT_2`t")
}

Describe 'Set-InlineFiles' {
    BeforeEach {
        Mock Get-Content { return $TestGenericFileContent }
        Mock Get-Content { return $TestRegFileContent } -ParameterFilter { $Path -match '.reg$' }
    }

    It 'Should inline English configuration files correctly' {
        Set-Variable -Option Constant Result (Set-InlineFiles $LocaleEnglish $TestConfigsPath $TestTemplateContent)

        Should -Invoke Get-Content -Exactly 14
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Windows\App associations.xml" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Apps\qBittorrent English.ini" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Windows\Base\Windows HKEY_LOCAL_MACHINE.reg" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Windows\Base\Windows English.reg" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }

        $Result | Should -Match 'TEST_TEMPLATE_CONTENT_1'
        $Result | Should -Match "Windows Registry Editor Version 5\.00`n`nTEST_REG_FILE_CONTENT_1`n\[HKEY_USERS\\DefaultUser\\Test\]`n&quot;TestValue&quot;=1`nTEST_REG_FILE_CONTENT_2"
        $Result | Should -Match "TEST_GENERIC_FILE_CONTENT_1`nTEST_GENERIC_FILE_CONTENT_2"
        $Result | Should -Match 'TEST_TEMPLATE_CONTENT_2'
    }

    It 'Should inline Russian configuration files correctly' {
        Set-Variable -Option Constant Result (Set-InlineFiles $LocaleRussian $TestConfigsPath $TestTemplateContent)

        Should -Invoke Get-Content -Exactly 14
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Windows\App associations.xml" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Apps\qBittorrent Russian.ini" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Windows\Base\Windows HKEY_LOCAL_MACHINE.reg" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestConfigsPath\Windows\Base\Windows Russian.reg" -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }

        $Result | Should -Match 'TEST_TEMPLATE_CONTENT_1'
        $Result | Should -Match "Windows Registry Editor Version 5\.00`n`nTEST_REG_FILE_CONTENT_1`n\[HKEY_USERS\\DefaultUser\\Test\]`n&quot;TestValue&quot;=1`nTEST_REG_FILE_CONTENT_2"
        $Result | Should -Match "TEST_GENERIC_FILE_CONTENT_1`nTEST_GENERIC_FILE_CONTENT_2"
        $Result | Should -Match 'TEST_TEMPLATE_CONTENT_2'
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { Set-InlineFiles $LocaleEnglish $TestConfigsPath $TestTemplateContent } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
    }
}
