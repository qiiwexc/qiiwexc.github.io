BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'

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
        Mock Write-LogInfo {}
        Mock Get-Content { return $TestPs1FileContent }
        Mock Set-Content {}
        Mock Copy-Item {}
        Mock Out-Success {}
    }

    It 'Should create batch script' {
        New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPs1FilePath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestBatchFilePath -and
            $Value -match "@echo off`n" -and
            $Value -match "%temp%\\$TestProjectName\.ps1" -and
            $Value -match '  powershell -ExecutionPolicy Bypass -Command ' -and
            $Value -match '::TEST_PS1_FILE_CONTENT_1' -and
            $Value -match '::TEST_PS1_FILE_CONTENT_2'
        }
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Copy-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestBatchFilePath -and
            $Destination -eq $TestVmBatchFilePath
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Copy-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Copy-Item failure' {
        Mock Copy-Item { throw $TestException }

        { New-BatchScript $TestProjectName $TestPs1FilePath $TestBatchFilePath $TestVmPath } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Copy-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
