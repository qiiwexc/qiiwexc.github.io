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

    Set-Variable -Option Constant TestArchiveFileName ([String]'TEST_ARCHIVE_FILE_NAME')
    Set-Variable -Option Constant TestExeFileName ([String]'TEST_EXE_FILE_NAME')

    Set-Variable -Option Constant TestArchiveBasePath ([String]'TEST_ARCHIVE_BASE_PATH')

    Set-Variable -Option Constant TestExtractionPath ([String]"$TestArchiveBasePath\$TestArchiveFileName")
    Set-Variable -Option Constant TestZipFilePath ([String]"$TestExtractionPath.zip")
    Set-Variable -Option Constant Test7zFilePath ([String]"$TestExtractionPath.7z")
    Set-Variable -Option Constant TestExeFilePath ([String]"$TestExtractionPath.exe")

    Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestExeFilePath")
    Set-Variable -Option Constant TestTemporaryExe ([String]"$TestExtractionPath\$TestExeFileName")
}

Describe 'Expand-Zip' {
    BeforeEach {
        Mock Test-Path { return $True } -ParameterFilter { $Path -eq $TestZipFilePath }
        Mock Test-Path { return $True } -ParameterFilter { $Path -eq $Test7zFilePath }
        Mock Write-ActivityProgress {}
        Mock Write-LogWarning {}
        Mock Get-ExecutableName { return $TestExeFileName }
        Mock Test-Path { return $False }
        Mock Initialize-AppDirectory {}
        Mock Remove-File {}
        Mock Remove-Directory {}
        Mock New-Directory {}
        Mock Expand-Archive {}
        Mock New-Object {}
        Mock Move-Item {}
        Mock Out-Success {}
        Mock Write-LogInfo {}
    }

    It 'Should throw when archive does not exist' {
        Mock Test-Path { return $False } -ParameterFilter { $Path -eq $TestZipFilePath }

        { Expand-Zip $TestZipFilePath } | Should -Throw 'Archive not found*'

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 0
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should throw for unsupported archive format' {
        { Expand-Zip "$TestExtractionPath.rar" } | Should -Throw 'Unsupported archive format*'

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 0
        Should -Invoke Get-ExecutableName -Exactly 0
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should expand zip file to default path' {
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestExeFileName")

        Expand-Zip $TestZipFilePath | Should -BeExactly $TestTargetExe

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 1 -ParameterFilter {
            $ZipName -eq "$TestArchiveFileName.zip" -and
            $ExtractionDir -eq $TestArchiveFileName
        }
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestTemporaryExe }
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke Remove-Directory -Exactly 2 -ParameterFilter { $DirectoryPath -eq $TestExtractionPath }
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $TestExtractionPath }
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1 -ParameterFilter {
            $Path -eq $TestZipFilePath -and
            $DestinationPath -eq $TestExtractionPath -and
            $Force -eq $True
        }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestTemporaryExe -and
            $Destination -eq $TestTargetExe -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should expand zip file to temporary path' {
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_APP_DIR\$TestExeFileName")

        Expand-Zip $TestZipFilePath -Temp | Should -BeExactly $TestTargetExe

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestTemporaryExe -and
            $Destination -eq $TestTargetExe -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should expand zip file with directory structure' {
        Set-Variable -Option Constant TestNestedExtractionExe ([String]"$TestExtractionPath\$TestArchiveFileName\$TestExeFileName")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestArchiveFileName\$TestExeFileName")

        Mock Get-ExecutableName { return "$TestArchiveFileName\$TestExeFileName" }

        Expand-Zip $TestZipFilePath | Should -BeExactly $TestTargetExe

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestNestedExtractionExe }
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter { $DirectoryPath -eq $TestExtractionPath }
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1 -ParameterFilter { $Path -eq $TestExtractionPath }
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1 -ParameterFilter {
            $Path -eq $TestZipFilePath -and
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
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestExeFileName")

        Mock Get-ExecutableName { return $TestExeFileName }

        $MockNamespace = [PSCustomObject]@{}
        $MockNamespace | Add-Member -MemberType ScriptMethod -Name Items -Value { return @('TEST') }
        $MockNamespace | Add-Member -MemberType ScriptMethod -Name CopyHere -Value { param($item, $flags) }

        $MockShell = [PSCustomObject]@{}
        $MockShell | Add-Member -MemberType ScriptMethod -Name NameSpace -Value { param($path) return $MockNamespace }

        Mock New-Object { return $MockShell } -ParameterFilter { $ComObject -eq 'Shell.Application' }

        Expand-Zip $Test7zFilePath | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 1
        Should -Invoke New-Object -Exactly 1 -ParameterFilter { $ComObject -eq 'Shell.Application' }
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should return existing file if already downloaded' {
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestExeFileName")

        Mock Test-Path { return $True }

        Expand-Zip $TestZipFilePath | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException } -ParameterFilter { $Path -eq $TestZipFilePath }

        { Expand-Zip $TestZipFilePath } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Get-ExecutableName -Exactly 0
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        { Expand-Zip $TestZipFilePath } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
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

        { Expand-Zip $TestZipFilePath } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
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

        { Expand-Zip $TestZipFilePath } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
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

        { Expand-Zip $TestZipFilePath } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
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

        { Expand-Zip $TestZipFilePath } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
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

        { Expand-Zip $TestZipFilePath } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Test-Path -Exactly 2
        Should -Invoke Get-ExecutableName -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
