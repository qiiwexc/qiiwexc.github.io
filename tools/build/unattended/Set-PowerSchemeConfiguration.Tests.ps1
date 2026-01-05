BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant ConfigsPath ([String]'.\src\3-configs')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{POWER_SCHEME_CONFIGURATION}`nTEST_TEMPLATE_CONTENT_2")

    Set-Variable -Option Constant TestFilePath ([String]"$ConfigsPath\Windows\Power settings.ps1")
}

Describe 'Set-PowerSchemeConfiguration' {
    It 'Should inline power scheme configuration correctly' {
        Set-Variable -Option Constant Result (Set-PowerSchemeConfiguration $ConfigsPath $TestTemplateContent)

        $Result | Should -Match 'powercfg /OverlaySetActive OVERLAY_SCHEME_MAX'
        $Result | Should -Match 'powercfg /SetAcValueIndex SCHEME_ALL 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0'
        $Result | Should -Match 'powercfg /SetDcValueIndex SCHEME_ALL 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0'
        $Result | Should -Match 'powercfg /SetAcValueIndex SCHEME_ALL 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1'
        $Result | Should -Match 'powercfg /SetDcValueIndex SCHEME_ALL 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1'
    }
}
