BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Read-JsonFile.ps1'

    Set-Variable -Option Constant ConfigsPath ([String]'.\src\3-configs')
    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{APP_REMOVAL_LIST}`nTEST_TEMPLATE_CONTENT_2")

    Set-Variable -Option Constant TestFileContent (
        [PSCustomObject[]]@(
            [PSCustomObject]@{ AppId = 'Microsoft.People'; Description = 'Test description 1' },
            [PSCustomObject]@{ AppId = 'Microsoft.Print3D'; Description = 'Test description 2' },
            [PSCustomObject]@{ AppId = 'Microsoft.windowscommunicationsapps'; Description = 'Test description 3' },
            [PSCustomObject]@{ AppId = 'Microsoft.WindowsMaps'; Description = 'Test description 4' },
            [PSCustomObject]@{ AppId = 'Microsoft.ZuneMusic'; Description = 'Test description 5' },
            [PSCustomObject]@{ AppId = 'Microsoft.ZuneVideo'; Description = 'Test description 6' })
    )
}

Describe 'Set-AppRemovalList' -Tag 'WIP' {
    BeforeEach {
        Mock Read-JsonFile { return $TestFileContent }
    }

    It 'Should inline app removal list correctly' {
        Set-Variable -Option Constant Result (Set-AppRemovalList $ConfigsPath $TestTemplateContent)

        $Result | Should -MatchExactly 'TEST_TEMPLATE_CONTENT_1'
        $Result | Should -MatchExactly "  'Microsoft.People';"
        $Result | Should -MatchExactly "  'Microsoft.Print3D';"
        $Result | Should -MatchExactly "  'Microsoft.windowscommunicationsapps';"
        $Result | Should -MatchExactly "  'Microsoft.WindowsMaps';"
        $Result | Should -MatchExactly "  'Microsoft.ZuneMusic';"
        $Result | Should -MatchExactly "  'Microsoft.ZuneVideo';"
        $Result | Should -MatchExactly "  'Microsoft.OneDrive';"
        $Result | Should -MatchExactly 'TEST_TEMPLATE_CONTENT_2'

        Should -Invoke Read-JsonFile -Exactly 1
        Should -Invoke Read-JsonFile -Exactly 1 -ParameterFilter {
            $Path -eq "$ConfigsPath\Windows\Tools\Debloat app list base.json"
        }
    }

    It 'Should handle Read-JsonFile failure' {
        Mock Read-JsonFile { throw $TestException }

        { Set-AppRemovalList $ConfigsPath $TestTemplateContent } | Should -Throw $TestException

        Should -Invoke Read-JsonFile -Exactly 1
    }
}
