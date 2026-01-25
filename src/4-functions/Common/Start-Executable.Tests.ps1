BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Remove-File.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestParentPath ([String]'TEST_PARENT_PATH')

    Set-Variable -Option Constant TestExecutable ([String]"$TestParentPath\TEST_EXECUTABLE")
    Set-Variable -Option Constant TestSwitches ([String]'TEST_SWITCHES')
}

Describe 'Start-Executable' {
    BeforeEach {
        Mock Write-ActivityProgress {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Write-LogDebug {}
        Mock Remove-File {}
    }

    It 'Should execute file without switches' {
        Start-Executable $TestExecutable

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $ArgumentList -eq $Null -and
            $WorkingDirectory -eq $TestParentPath -and
            $Wait -eq $Null
        }
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should execute file with custom switches' {
        Start-Executable $TestExecutable $TestSwitches

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $ArgumentList -eq $TestSwitches -and
            $WorkingDirectory -eq $TestParentPath -and
            $Wait -eq $Null
        }
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should execute file with -Silent switch' {
        Start-Executable $TestExecutable $TestSwitches -Silent

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $ArgumentList -eq $TestSwitches -and
            $WorkingDirectory -eq $Null -and
            $Wait -eq $True
        }
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $Silent -eq $True
        }
        Should -Invoke Out-Success -Exactly 2
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Start-Executable $TestExecutable } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Remove-File failure' {
        Mock Remove-File { throw $TestException }

        { Start-Executable $TestExecutable $TestSwitches -Silent } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }
}
