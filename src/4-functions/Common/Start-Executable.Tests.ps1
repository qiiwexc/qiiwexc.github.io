BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\Find-RunningProcesses.ps1"
    . "$PSScriptRoot\Remove-File.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\App lifecycle\Progressbar.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestParentPath ([String]'TEST_PARENT_PATH')

    Set-Variable -Option Constant TestProcessName ([String]'TEST_EXECUTABLE')
    Set-Variable -Option Constant TestExecutableName ([String]"$TestProcessName.exe")
    Set-Variable -Option Constant TestExecutable ([String]"$TestParentPath\$TestExecutableName")
    Set-Variable -Option Constant TestSwitches ([String]'TEST_SWITCHES')
}

Describe 'Start-Executable' {
    BeforeAll {
        Mock Find-RunningProcesses {}
        Mock Write-LogWarning {}
        Mock Write-ActivityProgress {}
        Mock Start-Process {}
        Mock Out-Success {}
        Mock Remove-File {}
    }

    It 'Should execute file without switches' {
        Start-Executable $TestExecutable

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Find-RunningProcesses -Exactly 1 -ParameterFilter { $ProcessNames -eq $TestProcessName }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $ArgumentList -eq $Null -and
            $WorkingDirectory -eq $TestParentPath -and
            $Wait -eq $Null
        }
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should execute file with custom switches' {
        Start-Executable $TestExecutable $TestSwitches

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $ArgumentList -eq $TestSwitches -and
            $WorkingDirectory -eq $TestParentPath -and
            $Wait -eq $Null
        }
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should execute file with -Silent switch' {
        Start-Executable $TestExecutable $TestSwitches -Silent

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Start-Process -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $ArgumentList -eq $TestSwitches -and
            $WorkingDirectory -eq $Null -and
            $Wait -eq $True
        }
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter {
            $FilePath -eq $TestExecutable -and
            $Silent -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should not execute file if already running' {
        Mock Find-RunningProcesses { return @(@{ ProcessName = $TestExecutableName }) }

        Start-Executable $TestExecutable

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should not look for a process named after a batch file' {
        Start-Executable "$TestParentPath\TEST_SCRIPT.bat"

        Should -Invoke Find-RunningProcesses -Exactly 0
        Should -Invoke Start-Process -Exactly 1
    }

    It 'Should handle Find-RunningProcesses failure' {
        Mock Find-RunningProcesses { throw $TestException }

        { Start-Executable $TestExecutable } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-Process -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Start-Process failure' {
        Mock Start-Process { throw $TestException }

        { Start-Executable $TestExecutable } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Remove-File failure' {
        Mock Remove-File { throw $TestException }

        { Start-Executable $TestExecutable $TestSwitches -Silent } | Should -Throw $TestException

        Should -Invoke Find-RunningProcesses -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-Process -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
