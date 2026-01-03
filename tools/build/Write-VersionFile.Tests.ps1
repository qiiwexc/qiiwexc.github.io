BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestVersion 'TEST_VERSION'
    Set-Variable -Option Constant TestFilePath 'TEST_FILE_PATH'
    Set-Variable -Option Constant TestException 'TEST_EXCEPTION'

    function Write-LogInfo {}
    function Out-Success {}
}

Describe 'Write-VersionFile' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Out-File {}
        Mock Out-Success {}
    }

    It 'Should write version to file' {
        Write-VersionFile $TestVersion $TestFilePath

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Out-File -Exactly 1
        Should -Invoke Out-File -Exactly 1 -ParameterFilter {
            $Encoding -eq 'ASCII' -and
            $FilePath -eq $TestFilePath -and
            $InputObject -eq $TestVersion
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Out-File failure' {
        Mock Out-File { throw $TestException }

        { Write-VersionFile $TestVersion $TestFilePath } | Should -Throw

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Out-File -Exactly 1
        Should -Invoke Out-File -Exactly 1 -ParameterFilter {
            $Encoding -eq 'ASCII' -and
            $FilePath -eq $TestFilePath -and
            $InputObject -eq $TestVersion
        }
        Should -Invoke Out-Success -Exactly 0
    }
}
