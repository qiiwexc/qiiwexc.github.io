BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Read-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant LocaleEnglish ([String]'English')
    Set-Variable -Option Constant LocaleRussian ([String]'Russian')

    Set-Variable -Option Constant TestConfigsPath ([String]'TEST_SOURCE_PATH')
    Set-Variable -Option Constant TestUnattendedPath ([String]'TEST_UNATTENDED_PATH')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{CONFIG_APP_ASSOCIATIONS}`n{CONFIG_QBITTORRENT_LOCALIZED}`n{CONFIG_SECURITY}`n{CONFIG_WINDOWS_LOCALISED}`nTEST_TEMPLATE_CONTENT_2")

    Set-Variable -Option Constant TestRegFileContent ([String]"TEST_REG_FILE_CONTENT_1`n[HKEY_CURRENT_USER\Test]`n`"TestValue`"=1`nTEST_REG_FILE_CONTENT_2 ")
    Set-Variable -Option Constant TestGenericFileContent ([String]"TEST_GENERIC_FILE_CONTENT_1`nTEST_GENERIC_FILE_CONTENT_2`t")
}

Describe 'Set-InlineFiles' {
    BeforeEach {
        Mock Read-TextFile { return $TestGenericFileContent }
        Mock Read-TextFile { return $TestRegFileContent } -ParameterFilter { $Path -match '.reg$' }
    }

    It 'Should inline English configuration files correctly' {
        Set-Variable -Option Constant Result (Set-InlineFiles $LocaleEnglish $TestConfigsPath $TestUnattendedPath $TestTemplateContent)

        Should -Invoke Read-TextFile -Exactly 15
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestUnattendedPath\App associations.xml" }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigsPath\Apps\qBittorrent English.ini" }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigsPath\Windows\Security.reg" }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigsPath\Windows\Baseline English.reg" }

        $Result | Should -MatchExactly 'TEST_TEMPLATE_CONTENT_1'
        $Result | Should -MatchExactly "Windows Registry Editor Version 5\.00`n`nTEST_REG_FILE_CONTENT_1`n\[HKEY_USERS\\DefaultUser\\Test\]`n&quot;TestValue&quot;=1`nTEST_REG_FILE_CONTENT_2"
        $Result | Should -MatchExactly "TEST_GENERIC_FILE_CONTENT_1`nTEST_GENERIC_FILE_CONTENT_2"
        $Result | Should -MatchExactly 'TEST_TEMPLATE_CONTENT_2'
    }

    It 'Should inline Russian configuration files correctly' {
        Set-Variable -Option Constant Result (Set-InlineFiles $LocaleRussian $TestConfigsPath $TestUnattendedPath $TestTemplateContent)

        Should -Invoke Read-TextFile -Exactly 15
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestUnattendedPath\App associations.xml" }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigsPath\Apps\qBittorrent Russian.ini" }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigsPath\Windows\Security.reg" }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq "$TestConfigsPath\Windows\Baseline Russian.reg" }

        $Result | Should -MatchExactly 'TEST_TEMPLATE_CONTENT_1'
        $Result | Should -MatchExactly "Windows Registry Editor Version 5\.00`n`nTEST_REG_FILE_CONTENT_1`n\[HKEY_USERS\\DefaultUser\\Test\]`n&quot;TestValue&quot;=1`nTEST_REG_FILE_CONTENT_2"
        $Result | Should -MatchExactly "TEST_GENERIC_FILE_CONTENT_1`nTEST_GENERIC_FILE_CONTENT_2"
        $Result | Should -MatchExactly 'TEST_TEMPLATE_CONTENT_2'
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { Set-InlineFiles $LocaleEnglish $TestConfigsPath $TestUnattendedPath $TestTemplateContent } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 2
    }
}
