BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\Common\Start-DownloadUnzipAndRun.ps1'
    . '.\src\4-functions\Configuration\Helpers\Import-RegistryConfiguration.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_PATH_APP_DIR')
    Set-Variable -Option Constant PATH_WORKING_DIR ([String]'TEST_PATH_WORKING_DIR')
    Set-Variable -Option Constant CONFIG_OFFICE_INSTALLER ([String]'TEST_CONFIG_OFFICE_INSTALLER_1 en-GB TEST_CONFIG_OFFICE_INSTALLER_2')
    Set-Variable -Option Constant CONFIG_MICROSOFT_OFFICE ([String]@('TEST_CONFIG_MICROSOFT_OFFICE'))

    Set-Variable -Option Constant TestOfficeUrl ([String]'{URL_OFFICE_INSTALLER}')

    Set-Variable -Option Constant TestConfigFileExecute ([String]"$PATH_APP_DIR\Office Installer.ini")
}

Describe 'Install-MicrosoftOffice' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Initialize-AppDirectory {}
        Mock Set-Content {}
        Mock Import-RegistryConfiguration {}
        Mock Start-DownloadUnzipAndRun {}
        Mock Write-LogWarning {}

        [Switch]$TestExecute = $True
        [String]$SYSTEM_LANGUAGE = 'en-GB'
    }

    It 'Should download Microsoft Office installer' {
        $TestExecute = $False

        Install-MicrosoftOffice -Execute:$TestExecute

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq "$PATH_WORKING_DIR\Office Installer.ini" -and
            $Value -eq $CONFIG_OFFICE_INSTALLER -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestOfficeUrl -and
            $Execute -eq $False
        }
    }

    It 'Should download and start Microsoft Office installer' {
        Install-MicrosoftOffice -Execute:$TestExecute

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestConfigFileExecute -and
            $Value -eq $CONFIG_OFFICE_INSTALLER -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1 -ParameterFilter {
            $AppName -eq 'Microsoft Office' -and
            $Content -eq $CONFIG_MICROSOFT_OFFICE
        }
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestOfficeUrl -and
            $Execute -eq $True
        }
    }

    It 'Should set config for Russian language' {
        $SYSTEM_LANGUAGE = 'ru-RU'

        Install-MicrosoftOffice -Execute:$TestExecute

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestConfigFileExecute -and
            $Value -eq 'TEST_CONFIG_OFFICE_INSTALLER_1 ru-RU TEST_CONFIG_OFFICE_INSTALLER_2' -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        Install-MicrosoftOffice -Execute:$TestExecute

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Import-RegistryConfiguration failure' {
        $TestExecute = $True

        Mock Import-RegistryConfiguration { throw $TestException }

        Install-MicrosoftOffice -Execute:$TestExecute

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Install-MicrosoftOffice -Execute:$TestExecute } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Import-RegistryConfiguration -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }
}
