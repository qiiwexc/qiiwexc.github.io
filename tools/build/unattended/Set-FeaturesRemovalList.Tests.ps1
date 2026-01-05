BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant ConfigsPath ([String]'.\src\3-configs')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{FEATURE_REMOVAL_LIST}`nTEST_TEMPLATE_CONTENT_2")
}

Describe 'Set-FeaturesRemovalList' {
    It 'Should inline feature removal list correctly' {
        Set-Variable -Option Constant Result (Set-FeaturesRemovalList $ConfigsPath $TestTemplateContent)

        $Result | Should -Match "  'MicrosoftWindowsPowerShellV2Root';"
        $Result | Should -Match "  'Recall';"
    }
}
