BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Backup-File' {
    BeforeAll {
        # Brackets, which a path that is not literal reads as a wildcard
        Set-Variable -Option Constant TestPath ([String]"$TestDrive\settings [1].ini")

        Mock Write-LogInfo {}
    }

    BeforeEach {
        Get-ChildItem -LiteralPath $TestDrive | Remove-Item -Force
    }

    It 'Should keep a copy of the file beside it' {
        Set-Content -LiteralPath $TestPath 'PREVIOUS_CONTENT'

        Backup-File $TestPath

        Get-Content -LiteralPath "$TestPath.bak" | Should -BeExactly 'PREVIOUS_CONTENT'
        Get-Content -LiteralPath $TestPath | Should -BeExactly 'PREVIOUS_CONTENT'
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Message -match ([Regex]::Escape("$TestPath.bak")) -and $Level -eq 1 }
    }

    It 'Should replace the copy a run before this one kept' {
        Set-Content -LiteralPath "$TestPath.bak" 'OLDER_CONTENT'
        Set-Content -LiteralPath $TestPath 'PREVIOUS_CONTENT'

        Backup-File $TestPath 2

        Get-Content -LiteralPath "$TestPath.bak" | Should -BeExactly 'PREVIOUS_CONTENT'
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter { $Level -eq 2 }
    }

    It 'Should do nothing when there is no file yet' {
        Backup-File $TestPath

        Test-Path -LiteralPath "$TestPath.bak" | Should -BeFalse
        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should handle Copy-Item failure' {
        Set-Content -LiteralPath $TestPath 'PREVIOUS_CONTENT'
        Mock Copy-Item { throw $TestException }

        { Backup-File $TestPath } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 0
    }
}
