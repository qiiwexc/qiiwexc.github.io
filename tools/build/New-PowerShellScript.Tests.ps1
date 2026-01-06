BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestSourcePathPath ([String]'TEST_BATCH_FILE_PATH')
    Set-Variable -Option Constant TestBuildPs1FilePath ([String]'TEST_BUILD_PS1_FILE_PATH')
    Set-Variable -Option Constant TestConfig ([Collections.Generic.List[Object]]@(@{key = 'KEY_1'; value = 'VALUE_1' }, @{key = 'KEY_2'; value = 'VALUE_2' }))

    Set-Variable -Option Constant TestPs1FilePath ([String]'\src\code\Test-File.ps1')
    Set-Variable -Option Constant TestConfigFilePath ([String]'\src\configs\ConfigFile.ini')

    Set-Variable -Option Constant TestSourceFileList (
        [Collections.Generic.List[Object]]@(
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
        Mock Write-LogInfo {}
        Mock Get-ChildItem { return $TestSourceFileList }
        Mock Get-Content { return $TestPs1FileContent } -ParameterFilter { $Path -eq $TestPs1FilePath }
        Mock Get-Content { return $TestConfigFileContent } -ParameterFilter { $Path -eq $TestConfigFilePath }
        Mock Set-Content {}
        Mock Out-Success {}
    }

    It 'Should create PowerShell script successfully' {
        New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig

        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Get-ChildItem -Exactly 1 -ParameterFilter {
            $Path -eq $TestSourcePathPath -and
            $Recurse -eq $True -and
            $File -eq $True
        }
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestPs1FilePath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestConfigFilePath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestBuildPs1FilePath -and
            $Value -match "^#region code > Test-File`n" -and
            $Value -match "TEST_PS1_FILE_CONTENT_1 VALUE_1`nVALUE_2 TEST_PS1_FILE_CONTENT_2" -and
            $Value -match "`n#endregion code > Test-File`n" -and
            $Value -match "`n#region configs > ConfigFile`n" -and
            $Value -match "Set-Variable -Option Constant CONFIG_CONFIGFILE 'TEST_CONFIG_KEY_1=`"TEST_CONFIG_VALUE_1`"`nTEST_CONFIG_KEY_2=TEST_CONFIG_VALUE_2" -and
            $Value -match "'" -and
            $Value -match "`n#endregion configs > ConfigFile"
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-ChildItem failure' {
        Mock Get-ChildItem { throw $TestException }

        { New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig } | Should -Throw

        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Get-Content -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException } -ParameterFilter { $Path -match '.+' }

        { New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig } | Should -Throw

        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { New-PowerShellScript $TestSourcePathPath $TestBuildPs1FilePath $TestConfig } | Should -Throw

        Should -Invoke Get-ChildItem -Exactly 1
        Should -Invoke Get-Content -Exactly 2
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
