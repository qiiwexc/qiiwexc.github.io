BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Start-DownloadUnzipAndRun.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestRegistryKey ([String]'HKCU:\Software\Unchecky')
    Set-Variable -Option Constant TestUncheckyUrl ([String]'{URL_UNCHECKY}')
}

Describe 'Install-Unchecky' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Test-Path { return $False }
        Mock Write-LogDebug {}
        Mock New-Item {}
        Mock Set-ItemProperty {}
        Mock Start-DownloadUnzipAndRun {}
        Mock Write-LogWarning {}

        [Switch]$TestExecute = $True
        [Switch]$TestSilent = $True
    }

    It 'Should download Unchecky' {
        $TestExecute = $False
        $TestSilent = $False

        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-Path -Exactly 0
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-ItemProperty -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestUncheckyUrl -and
            $Execute -eq $False -and
            $Silent -eq $False -and
            $Params -eq ''
        }
    }

    It 'Should install Unchecky' {
        $TestSilent = $False

        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Test-Path -Exactly 1 -ParameterFilter { $Path -eq $TestRegistryKey }
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke New-Item -Exactly 1 -ParameterFilter { $Path -eq $TestRegistryKey }
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq $TestRegistryKey -and
            $Name -eq 'HideTrayIcon' -and
            $Value -eq 1
        }
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestUncheckyUrl -and
            $Execute -eq $True -and
            $Silent -eq $False -and
            $Params -eq ''
        }
    }

    It 'Should install Unchecky silently' {
        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestUncheckyUrl -and
            $Execute -eq $True -and
            $Silent -eq $True -and
            $Params -eq '-install -no_desktop_icon'
        }
    }

    It 'Should handle Test-Path failure' {
        Mock Test-Path { throw $TestException }

        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 0
        Should -Invoke New-Item -Exactly 0
        Should -Invoke Set-ItemProperty -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle New-Item failure' {
        Mock New-Item { throw $TestException }

        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Set-ItemProperty failure' {
        Mock Set-ItemProperty { throw $TestException }

        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-Path -Exactly 1
        Should -Invoke Write-LogDebug -Exactly 1
        Should -Invoke New-Item -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }
}
