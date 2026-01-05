BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant SourcePath ([String]'.\src')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{KEYBOARD1}`n{LOCALE1}`n{UI_LANGUAGE}`nTEST_TEMPLATE_CONTENT_2")
}

Describe 'Set-LocaleSettings' {
    It 'Should inline English locale settings correctly' {
        Set-LocaleSettings 'English' $TestTemplateContent | Should -BeExactly "TEST_TEMPLATE_CONTENT_1`n0809`nen-GB`nen-US`nTEST_TEMPLATE_CONTENT_2"
    }

    It 'Should inline Russian locale settings correctly' {
        Set-LocaleSettings 'Russian' $TestTemplateContent | Should -BeExactly "TEST_TEMPLATE_CONTENT_1`n0419`nru-RU`nru-RU`nTEST_TEMPLATE_CONTENT_2"
    }
}
