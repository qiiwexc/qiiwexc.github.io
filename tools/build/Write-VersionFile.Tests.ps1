BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Write-File.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestVersion ([String]'TEST_VERSION')
    Set-Variable -Option Constant TestFilePath ([String]'TEST_FILE_PATH')
}

Describe 'Write-VersionFile' {
    BeforeEach {
        Mock New-Activity {}
        Mock Write-File {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should write version to file' {
        Write-VersionFile $TestVersion $TestFilePath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-File -Exactly 1
        Should -Invoke Write-File -Exactly 1 -ParameterFilter {
            $Path -eq $TestFilePath -and
            $Content -eq $TestVersion
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Set-Content failure' {
        Mock Write-File { throw $TestException }

        { Write-VersionFile $TestVersion $TestFilePath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-File -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
