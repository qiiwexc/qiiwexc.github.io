BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant ConfigsPath ([String]'.\src\3-configs')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{CAPABILITY_REMOVAL_LIST}`nTEST_TEMPLATE_CONTENT_2")
}

Describe 'Set-CapabilitiesRemovalList' {
    It 'Should inline capability removal list correctly' {
        Set-Variable -Option Constant Result (Set-CapabilitiesRemovalList $ConfigsPath $TestTemplateContent)

        $Result | Should -Match "  'App.Support.QuickAssist';"
        $Result | Should -Match "  'App.StepsRecorder';"
    }
}
