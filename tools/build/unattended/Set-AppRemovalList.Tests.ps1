BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant ConfigsPath ([String]'.\src\3-configs')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{APP_REMOVAL_LIST}`nTEST_TEMPLATE_CONTENT_2")
}

Describe 'Set-AppRemovalList' {
    It 'Should inline app removal list correctly' {
        Set-Variable -Option Constant Result (Set-AppRemovalList $ConfigsPath $TestTemplateContent)

        $Result | Should -Match "  'Microsoft.OneDrive';"
        $Result | Should -Match "  'Microsoft.People';"
        $Result | Should -Match "  'Microsoft.Print3D';"
        $Result | Should -Match "  'Microsoft.windowscommunicationsapps';"
        $Result | Should -Match "  'Microsoft.WindowsMaps';"
        $Result | Should -Match "  'Microsoft.ZuneMusic';"
        $Result | Should -Match "  'Microsoft.ZuneVideo';"
        $Result | Should -Not -Match '#'
    }
}
