BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Progressbar.ps1'
    . '.\src\4-functions\Common\Expand-Zip.ps1'
    . '.\src\4-functions\Common\Start-Download.ps1'
    . '.\src\4-functions\Common\Start-Executable.ps1'
    . '.\src\4-functions\Common\Test-AntivirusEnabled.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestUrl ([String]'TEST_URL.ext')
    Set-Variable -Option Constant TestUrlZip ([String]'TEST_URL.zip')
    Set-Variable -Option Constant TestUrl7z ([String]'TEST_URL.7z')
    Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME')
    Set-Variable -Option Constant TestParams ([String]'TEST_PARAMS')
    Set-Variable -Option Constant TestConfigFile ([String]'TEST_CONFIG_FILE')
    Set-Variable -Option Constant TestConfiguration ([String]'TEST_CONFIGURATION')

    Set-Variable -Option Constant TestParentPath ([String]'TEST_PARENT_PATH')

    Set-Variable -Option Constant TestDownloadedFile ([String]"$TestParentPath\TEST_DOWNLOADED_FILE")
    Set-Variable -Option Constant TestExecutable ([String]"$TestParentPath\TEST_EXECUTABLE")
}

Describe 'Start-DownloadUnzipAndRun' {
    BeforeEach {
        Mock New-Activity {}
        Mock Start-Download { return $TestDownloadedFile }
        Mock Out-Failure {}
        Mock Write-ActivityCompleted {}
        Mock Expand-Zip { return $TestExecutable }
        Mock Set-Content {}
        Mock Start-Executable {}
    }

    It 'Should download a file to the default location' {
        Start-DownloadUnzipAndRun $TestUrl | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Start-Download -Exactly 1 -ParameterFilter {
            $URL -eq $TestUrl -and
            $FileName -eq $Null -and
            $Temp -eq $False
        }
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download a file to a specified location' {
        Start-DownloadUnzipAndRun $TestUrl $TestFileName | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Start-Download -Exactly 1 -ParameterFilter {
            $URL -eq $TestUrl -and
            $SaveAs -eq $TestFileName -and
            $Temp -eq $False
        }
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download a file and set configuration' {
        Start-DownloadUnzipAndRun $TestUrl -ConfigFile $TestConfigFile -Configuration $TestConfiguration | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$TestParentPath\$TestConfigFile" -and
            $Value -eq $TestConfiguration -and
            $NoNewline -eq $True
        }
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download and unzip a zip file' {
        Start-DownloadUnzipAndRun $TestUrlZip | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Start-Download -Exactly 1 -ParameterFilter {
            $URL -eq $TestUrlZip -and
            $FileName -eq $Null -and
            $Temp -eq $True
        }
        Should -Invoke Expand-Zip -Exactly 1
        Should -Invoke Expand-Zip -Exactly 1 -ParameterFilter {
            $ZipPath -eq $TestDownloadedFile -and
            $Temp -eq $False
        }
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download and unzip a 7z file' {
        Start-DownloadUnzipAndRun $TestUrl7z | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Start-Download -Exactly 1 -ParameterFilter {
            $URL -eq $TestUrl7z -and
            $FileName -eq $Null -and
            $Temp -eq $True
        }
        Should -Invoke Expand-Zip -Exactly 1
        Should -Invoke Expand-Zip -Exactly 1 -ParameterFilter {
            $ZipPath -eq $TestDownloadedFile -and
            $Temp -eq $False
        }
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download and run a file' {
        Start-DownloadUnzipAndRun $TestUrl -Execute | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 1
        Should -Invoke Start-Executable -Exactly 1 -ParameterFilter {
            $Executable -eq $TestDownloadedFile -and
            $Switches -eq '' -and
            $Silent -eq $False
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download and run a file with silent switch' {
        Start-DownloadUnzipAndRun $TestUrl -Execute -Silent | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 1
        Should -Invoke Start-Executable -Exactly 1 -ParameterFilter {
            $Executable -eq $TestDownloadedFile -and
            $Switches -eq '' -and
            $Silent -eq $True
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download and run a file with parameters' {
        Start-DownloadUnzipAndRun $TestUrl -Params $TestParams -Execute | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 1
        Should -Invoke Start-Executable -Exactly 1 -ParameterFilter {
            $Executable -eq $TestDownloadedFile -and
            $Switches -eq $TestParams -and
            $Silent -eq $False
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should download and run a zipped file' {
        Start-DownloadUnzipAndRun $TestUrlZip -Execute | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 1
        Should -Invoke Expand-Zip -Exactly 1 -ParameterFilter {
            $ZipPath -eq $TestDownloadedFile -and
            $Temp -eq $True
        }
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 1
        Should -Invoke Start-Executable -Exactly 1 -ParameterFilter {
            $Executable -eq $TestExecutable -and
            $Switches -eq '' -and
            $Silent -eq $False
        }
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
    }

    It 'Should handle Start-Download failure' {
        Mock Start-Download { throw $TestException }

        Start-DownloadUnzipAndRun $TestUrl | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $False }
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { Start-DownloadUnzipAndRun $TestUrl -ConfigFile $TestConfigFile -Configuration $TestConfiguration } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Expand-Zip failure' {
        Mock Expand-Zip { throw $TestException }

        Start-DownloadUnzipAndRun $TestUrlZip | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $False }
    }

    It 'Should handle Start-Executable failure' {
        Mock Start-Executable { throw $TestException }

        Start-DownloadUnzipAndRun $TestUrl -Execute | Should -BeNullOrEmpty

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Start-Download -Exactly 1
        Should -Invoke Expand-Zip -Exactly 0
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Start-Executable -Exactly 1
        Should -Invoke Out-Failure -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $False }
    }

    Context 'AVWarning' {
        BeforeEach {
            $script:AV_WARNINGS_SHOWN = [Collections.Generic.HashSet[String]]::new()
        }

        It 'Should show AV warning and skip download on first call when antivirus is enabled' {
            Mock Test-AntivirusEnabled { return $True }
            Mock Write-LogWarning {}

            Start-DownloadUnzipAndRun $TestUrl -AVWarning | Should -BeNullOrEmpty

            Should -Invoke Test-AntivirusEnabled -Exactly 1
            Should -Invoke Write-LogWarning -Exactly 1
            Should -Invoke Start-Download -Exactly 0
            Should -Invoke Write-ActivityCompleted -Exactly 1
            Should -Invoke Write-ActivityCompleted -Exactly 1 -ParameterFilter { $Success -eq $Null }
        }

        It 'Should proceed with download on second call for the same URL' {
            Mock Test-AntivirusEnabled { return $True }
            Mock Write-LogWarning {}

            Start-DownloadUnzipAndRun $TestUrl -AVWarning | Should -BeNullOrEmpty
            Start-DownloadUnzipAndRun $TestUrl -AVWarning | Should -BeNullOrEmpty

            Should -Invoke Test-AntivirusEnabled -Exactly 2
            Should -Invoke Write-LogWarning -Exactly 1
            Should -Invoke Start-Download -Exactly 1
        }

        It 'Should not show AV warning when antivirus is disabled' {
            Mock Test-AntivirusEnabled { return $False }
            Mock Write-LogWarning {}

            Start-DownloadUnzipAndRun $TestUrl -AVWarning | Should -BeNullOrEmpty

            Should -Invoke Test-AntivirusEnabled -Exactly 1
            Should -Invoke Write-LogWarning -Exactly 0
            Should -Invoke Start-Download -Exactly 1
        }

        It 'Should not check antivirus when AVWarning is not set' {
            Mock Test-AntivirusEnabled {}

            Start-DownloadUnzipAndRun $TestUrl | Should -BeNullOrEmpty

            Should -Invoke Test-AntivirusEnabled -Exactly 0
            Should -Invoke Start-Download -Exactly 1
        }
    }
}
