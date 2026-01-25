BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

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
    Set-Variable -Option Constant TestZipFile ([String]'TEST_ZIP_FILE.zip')
    Set-Variable -Option Constant TestZipPath ([String]"$TestZipBasePath\$TestZipFile")
    Set-Variable -Option Constant TestSaveAs ([String]'TEST_SAVE_AS')

    Set-Variable -Option Constant TestTempPath ([String]"$PATH_APP_DIR\$TestZipFile")
    Set-Variable -Option Constant TestTempPathSaveAs ([String]"$PATH_APP_DIR\$TestSaveAs")

    Set-Variable -Option Constant TestSavePath ([String]"$PATH_WORKING_DIR\$TestZipFile")
    Set-Variable -Option Constant TestSavePathSaveAs ([String]"$PATH_WORKING_DIR\$TestSaveAs")
}

Describe 'Expand-Zip' {
    BeforeEach {
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

        [Bool]$OS_64_BIT = $True
    }

    It 'Should expand zip file to default path' {
        Set-Variable -Option Constant TestFileName ([String]'TEST_ZIP_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionExe -and
            $Destination -eq $TestTargetExe -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand zip file to temporary path' {
        Set-Variable -Option Constant TestFileName ([String]'TEST_ZIP_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_APP_DIR\$TestFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_APP_DIR\$TestFileName.exe")

        Expand-Zip $TestZipFileName -Temp | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
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
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand Office Installer zip file on 64-bit OS' {
        Set-Variable -Option Constant TestFileName ([String]'Office_Installer')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'Office Installer')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionExe -and
            $Destination -eq $TestTargetExe -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand Office Installer zip file on 32-bit OS' {
        [Bool]$OS_64_BIT = $False

        Set-Variable -Option Constant TestFileName ([String]'Office_Installer')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'Office Installer x86')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionExe -and
            $Destination -eq $TestTargetExe -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand CPU-Z zip file on 64-bit OS' {
        Set-Variable -Option Constant TestFileName ([String]'cpu-z_1.2.3')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'cpuz_x64')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionPath -and
            $Destination -eq $PATH_WORKING_DIR -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand CPU-Z zip file on 32-bit OS' {
        [Bool]$OS_64_BIT = $False

        Set-Variable -Option Constant TestFileName ([String]'cpu-z_1.2.3')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'cpuz_x32')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionPath -and
            $Destination -eq $PATH_WORKING_DIR -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand SDI zip file on 64-bit OS' {
        Set-Variable -Option Constant TestFileName ([String]'SDI_1.2.3')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'SDI64-drv')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionPath -and
            $Destination -eq $PATH_WORKING_DIR -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand SDI zip file on 32-bit OS' {
        [Bool]$OS_64_BIT = $False

        Set-Variable -Option Constant TestFileName ([String]'SDI_1.2.3')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'SDI-drv')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionPath -and
            $Destination -eq $PATH_WORKING_DIR -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand Ventoy zip file' {
        Set-Variable -Option Constant TestFileName ([String]'ventoy_1.2.3')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'Ventoy2Disk')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName\$TestFileName\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionPath -and
            $Destination -eq $PATH_WORKING_DIR -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should expand Victoria zip file' {
        Set-Variable -Option Constant TestFileName ([String]'victoria_1.2.3')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        Set-Variable -Option Constant TestExeFileName ([String]'Victoria')
        Set-Variable -Option Constant TestExtractionExe ([String]"$TestExtractionPath\$TestFileName\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestTargetExe ([String]"$PATH_WORKING_DIR\$TestFileName\$TestFileName\$TestExeFileName.exe")
        Set-Variable -Option Constant TestExeFile ([String]"$PATH_WORKING_DIR\$TestFileName\$TestFileName\$TestExeFileName.exe")

        Expand-Zip $TestZipFileName | Should -BeExactly $TestExeFile

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestExtractionExe }
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
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
        Should -Invoke Remove-File -Exactly 1 -ParameterFilter { $FilePath -eq $TestZipFileName }
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Move-Item -Exactly 1 -ParameterFilter {
            $Path -eq $TestExtractionPath -and
            $Destination -eq $PATH_WORKING_DIR -and
            $Force -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 0
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should handle Remove-File failure' {
        Mock Remove-File { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should handle Remove-Directory failure' {
        Mock Remove-Directory { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 0
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should handle New-Directory failure' {
        Mock New-Directory { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should handle Expand-Archive failure' {
        Mock Expand-Archive { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should handle New-Object failure' {
        Mock New-Object { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.7z")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 0
        Should -Invoke New-Object -Exactly 1
        Should -Invoke Move-Item -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 0
    }

    It 'Should handle Move-Item failure' {
        Mock Move-Item { throw $TestException }

        Set-Variable -Option Constant TestFileName ([String]'Office_Installer')

        Set-Variable -Option Constant TestExtractionPath ([String]"$TestZipBasePath\$TestFileName")
        Set-Variable -Option Constant TestZipFileName ([String]"$TestExtractionPath.zip")

        { Expand-Zip $TestZipFileName } | Should -Throw $TestException

        Should -Invoke Write-ActivityProgress -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Remove-File -Exactly 2
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke New-Directory -Exactly 1
        Should -Invoke Expand-Archive -Exactly 1
        Should -Invoke New-Object -Exactly 0
        Should -Invoke Move-Item -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Write-LogInfo -Exactly 0
    }
}
