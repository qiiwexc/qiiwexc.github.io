BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Get-ExecutableName.ps1'
    . '.\src\4-functions\Common\New-Directory.ps1'
    . '.\src\4-functions\Common\Remove-Directory.ps1'
    . '.\src\4-functions\Common\Remove-File.ps1'
    . '.\src\4-functions\App lifecycle\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')
    Set-Variable -Option Constant PATH_WORKING_DIR ([String]'TEST_PATH_WORKING_DIR')

    Set-Variable -Option Constant TestZipBasePath ([String]'TEST_ZIP_BASE_PATH')
}

Describe 'Expand-Zip' {
    BeforeEach {
        Mock Test-Path { return $True }
        Mock Write-ActivityProgress {}
        Mock Initialize-AppDirectory {}
        Mock Remove-File {}
        Mock Remove-Directory {}
        Mock New-Directory {}
        Mock Expand-Archive {}
        Mock New-Object {}
        Mock Move-Item {}
        Mock Out-Success {}
        Mock Write-LogInfo {}
        Mock Get-ExecutableName { return 'TEST_FILE_NAME.exe' }
    }

    It 'Should throw when archive does not exist' {
        Mock Test-Path { return $False }

        { Expand-Zip 'C:\nonexistent\file.zip' } | Should -Throw '*Archive not found*'

        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-ActivityProgress -Exactly 0
    }

    It 'Should throw for unsupported archive format' {
        { Expand-Zip 'C:\path\file.rar' } | Should -Throw '*Unsupported archive format*'
    }

    It 'Should expand zip file to default path' {
        Set-Variable -Option Constant TestFileName ([String]'TEST_ZIP_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName.exe")

        Mock Get-ExecutableName { return "$TestFileName.exe" }

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1 -ParameterFilter {
            $ZipName -eq "$TestFileName.zip" -and
            $ExtractionDir -eq $TestFileName
        }
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke Remove-Directory -Exactly 2 -ParameterFilter { $DirectoryPath -eq $TestExtractionPath }
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $TestExtractionPath }
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1 -ParameterFilter {
            $Path -eq $TestZipFileName -and
            $DestinationPath -eq $TestExtractionPath -and
            $Force -eq $True
        }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionExe -and
            $Destination -eq $TestTargetExe -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should expand zip file to temporary path' {
        Set-Variable -Option Constant TestFileName ([String]'TEST_ZIP_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_APP_DIR\$TestFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_APP_DIR\$TestFileName.exe")

        Mock Get-ExecutableName { return "$TestFileName.exe" }

        Expand-Zip $TestZipFileName -Temp | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionExe -and
            $Destination -eq $TestTargetExe -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should expand zip file with directory structure' {
        Set-Variable -Option Constant TestFileName ([String]'TEST_ZIP_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'nested_executable')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")

        Mock Get-ExecutableName { return "$TestFileName\$TestExeFileName.exe" }

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter { $DirectoryPath -eq $TestExtractionPath }
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $TestExtractionPath }
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1 -ParameterFilter {
            $Path -eq $TestZipFileName -and
            $DestinationPath -eq $TestExtractionPath -and
            $Force -eq $True
        }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionPath -and
            $Destination -eq $PATH_WORKING_DIR -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should expand 7z file using Shell.Application' {
        Set-Variable -Option Constant TestFileName ([String]'TEST_7Z_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant Test7zFileName ([String]"$TestExtractionPath.7z")

        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName.exe")

        Mock Get-ExecutableName { return "$TestFileName.exe" }

        $MockNamespace = [PSCustomObject]@{}
        $MockNamespace | Add-Member -MemberType ScriptMethod -Name Items -Value { return @() }
        $MockNamespace | Add-Member -MemberType ScriptMethod -Name CopyHere -Value { param($item, $flags) }

        $MockShell = [PSCustomObject]@{}
        $MockShell | Add-Member -MemberType ScriptMethod -Name NameSpace -Value { param($path) return $MockNamespace }

        Mock New-Object { return $MockShell } -ParameterFilter { $ComObject -eq 'Shell.Application' }

        Expand-Zip $Test7zFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 1
        Should -Invoke New-Object -Exactly 1 -ParameterFilter { $ComObject -eq 'Shell.Application' }
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Remove-File failure' {
        Mock Remove-File { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Remove-Directory failure' {
        Mock Remove-Directory { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Expand-Archive failure' {
        Mock Expand-Archive { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Move-Item failure' {
        Mock Move-Item { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
