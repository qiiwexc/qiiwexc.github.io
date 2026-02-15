BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestExtractionPath ([String]'TEST_EXTRACTION_PATH')
    Set-Variable -Option Constant TestZipPath ([String]'TEST_ZIP_PATH')
}

Describe 'Invoke-7Zip' {
    It 'Should invoke 7-Zip executable' {
        Set-Variable -Option Constant PATH_7ZIP_EXE ([String]'Write-Output')

        { Invoke-7Zip $TestExtractionPath $TestZipPath } | Should -Not -Throw
    }

    It 'Should handle executable not found' {
        Set-Variable -Option Constant PATH_7ZIP_EXE ([String]'NONEXISTENT_7ZIP_EXE_PATH')

        { Invoke-7Zip $TestExtractionPath $TestZipPath } | Should -Throw
    }
}
