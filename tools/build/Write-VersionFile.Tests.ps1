BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Write-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestVersion ([Version]'1.2.3')
    Set-Variable -Option Constant TestFilePath ([String]'TEST_FILE_PATH')
}

Describe 'Write-VersionFile' {
    BeforeEach {
        Mock New-Activity {}
        Mock Write-TextFile {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should write version to file' {
        Write-VersionFile $TestVersion $TestFilePath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestFilePath -and
            $Content -eq $TestVersion -and
            $Normalize -eq $True
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Set-Content failure' {
        Mock Write-TextFile { throw $TestException }

        { Write-VersionFile $TestVersion $TestFilePath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
