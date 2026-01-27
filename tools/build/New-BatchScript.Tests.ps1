BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-TextFile.ps1'
    . '.\tools\common\Write-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestProjectName ([String]'TEST_PROJECT_NAME')
    Set-Variable -Option Constant TestPs1FilePath ([String]'TEST_PS1_FILE_PATH')
    Set-Variable -Option Constant TestBatchFilePath ([String]'TEST_BATCH_FILE_PATH')
    Set-Variable -Option Constant TestVmPath ([String]'TEST_VM_PATH')

    Set-Variable -Option Constant TestPs1FileContent ([String]"TEST_PS1_FILE_CONTENT_1`nTEST_PS1_FILE_CONTENT_2")

    Set-Variable -Option Constant TestVmBatchFilePath ([String]"$TestVmPath\$TestProjectName.bat")
}

Describe 'New-BatchScript' {
    BeforeEach {
        Mock New-Activity {}
        Mock Write-LogInfo {}
        Mock Read-TextFile { return $TestPs1FileContent }
        Mock Write-TextFile {}
        Mock Copy-Item {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should create batch script' {
        New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestPs1FilePath }
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBatchFilePath -and
            # $Content -match "@echo off`n" -and
            $Content -match "%temp%\\$TestProjectName\.ps1" -and
            $Content -match '  powershell -ExecutionPolicy Bypass -Command ' -and
            $Content -match '::TEST_PS1_FILE_CONTENT_1' -and
            $Content -match '::TEST_PS1_FILE_CONTENT_2'
        }
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Copy-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestBatchFilePath -and
            $Destination -eq $TestVmBatchFilePath
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-TextFile failure' {
        Mock Write-TextFile { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Copy-Item failure' {
        Mock Copy-Item { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
