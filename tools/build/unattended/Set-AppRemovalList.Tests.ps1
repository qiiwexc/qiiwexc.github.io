BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Read-TextFile.ps1'

    Set-Variable -Option Constant ConfigsPath ([String]'.\src\3-configs')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{APP_REMOVAL_LIST}`nTEST_TEMPLATE_CONTENT_2")

    Set-Variable -Option Constant TestFileContent (
        [String[]]@('Microsoft.People # Test comment 1',
            'Microsoft.Print3D',
            'Microsoft.windowscommunicationsapps',
            'Microsoft.WindowsMaps # Test comment 2',
            'Microsoft.ZuneMusic',
            'Microsoft.ZuneVideo')
    )
}

Describe 'Set-AppRemovalList' {
    BeforeEach {
        Mock Read-TextFile { return $TestFileContent }
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

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq "$ConfigsPath\Windows\Tools\Debloat app list.txt" -and
            $AsList -eq $True
        }
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { Set-AppRemovalList $ConfigsPath $TestTemplateContent } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 1
    }
}
