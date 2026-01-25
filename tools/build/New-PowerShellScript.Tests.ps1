BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'
    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-TextFile.ps1'
    . '.\tools\common\Write-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestSourcePathPath ([String]'TEST_BATCH_FILE_PATH')
    Set-Variable -Option Constant TestBuildPs1FilePath ([String]'TEST_BUILD_PS1_FILE_PATH')
    Set-Variable -Option Constant TestConfig ([PSCustomObject[]]@(@{key = 'KEY_1'; value = 'VALUE_1' }, @{key = 'KEY_2'; value = 'VALUE_2' }))

    Set-Variable -Option Constant TestPs1FilePath ([String]'\src\code\Test-File.ps1')
    Set-Variable -Option Constant TestConfigFilePath ([String]'\src\configs\ConfigFile.ini')

    Set-Variable -Option Constant TestSourceFileList (
        [PSCustomObject[]]@(
            @{Name = 'Test-File.ps1'; FullName = $TestPs1FilePath },
            @{Name = 'Test-File.Tests.ps1'; FullName = '\src\code\Test-File.Tests.ps1' },
            @{Name = 'ConfigFile.ini'; FullName = $TestConfigFilePath }
        )
    )

    Set-Variable -Option Constant TestPs1FileContent ([String]"TEST_PS1_FILE_CONTENT_1 {KEY_1}`n{KEY_2} TEST_PS1_FILE_CONTENT_2 ")
    Set-Variable -Option Constant TestConfigFileContent ([String]"TEST_CONFIG_KEY_1='TEST_CONFIG_VALUE_1'`nTEST_CONFIG_KEY_2=TEST_CONFIG_VALUE_2 ")
}

Describe 'New-PowerShellScript' {
    BeforeEach {
        Mock New-Activity {}
        Mock Get-ChildItem { return $TestSourceFileList }
        Mock Read-TextFile { return $TestPs1FileContent } -ParameterFilter { $Path -eq $TestPs1FilePath }
        Mock Read-TextFile { return $TestConfigFileContent } -ParameterFilter { $Path -eq $TestConfigFilePath }
        Mock Write-LogInfo {}
        Mock Write-TextFile {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should create PowerShell script' {
        New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Get-ChildItem -Exactly 1 -ParameterFilter {
            $Path -eq $TestSourcePathPath -and
            $Recurse -eq $True -and
            $File -eq $True
        }
        Should -Invoke Read-TextFile -Exactly 2
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestPs1FilePath }
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestConfigFilePath }
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildPs1FilePath -and
            $Content -match "^#region code > Test-File`n" -and
            $Content -match "TEST_PS1_FILE_CONTENT_1 VALUE_1`nVALUE_2 TEST_PS1_FILE_CONTENT_2" -and
            $Content -match "`n#endregion code > Test-File`n" -and
            $Content -match "`n#region configs > ConfigFile`n" -and
            $Content -match "Set-Variable -Option Constant CONFIG_CONFIGFILE 'TEST_CONFIG_KEY_1=`"TEST_CONFIG_VALUE_1`"`nTEST_CONFIG_KEY_2=TEST_CONFIG_VALUE_2" -and
            $Content -match "'" -and
            $Content -match "`n#endregion configs > ConfigFile"
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Get-ChildItem failure' {
        Mock Get-ChildItem { throw $TestException }

        { New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Read-TextFile -Exactly 0
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException } -ParameterFilter { $Path -match '.+' }

        { New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-TextFile failure' {
        Mock Write-TextFile { throw $TestException }

        { New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Read-TextFile -Exactly 2
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }
}
