BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\New-RegistryKeyIfMissing.ps1'
    . '.\src\4-functions\Common\Start-DownloadUnzipAndRun.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestRegistryKey ([String]'HKCU:\Software\Unchecky')
    Set-Variable -Option Constant TestUncheckyUrl ([String]'{URL_UNCHECKY}')
}

Describe 'Install-Unchecky' {
    BeforeEach {
        Mock New-RegistryKeyIfMissing { }
        Mock Set-ItemProperty { }
        Mock Start-DownloadUnzipAndRun { }

        [Switch]$TestExecute = $True
        [Switch]$TestSilent = $True
    }

    It 'Should download Unchecky successfully' {
        $TestExecute = $False
        $TestSilent = $False

        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke New-RegistryKeyIfMissing -Exactly 0
        Should -Invoke Set-ItemProperty -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestUncheckyUrl -and
            $Execute -eq $False -and
            $Silent -eq $False -and
            $Params -eq ''
        }
    }

    It 'Should install Unchecky successfully' {
        $TestSilent = $False

        Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent

        Should -Invoke New-RegistryKeyIfMissing -Exactly 1
        Should -Invoke New-RegistryKeyIfMissing -Exactly 1 -ParameterFilter { $RegistryPath -eq $TestRegistryKey }
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1 -ParameterFilter {
            $Path -eq $TestRegistryKey -and
            $Name -eq 'HideTrayIcon' -and
            $Value -eq 1
        }
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

        Should -Invoke New-RegistryKeyIfMissing -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1 -ParameterFilter {
            $URL -eq $TestUncheckyUrl -and
            $Execute -eq $True -and
            $Silent -eq $True -and
            $Params -eq '-install -no_desktop_icon'
        }
    }

    It 'Should handle New-RegistryKeyIfMissing failure' {
        Mock New-RegistryKeyIfMissing { throw $TestException }

        { Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent } | Should -Throw

        Should -Invoke New-RegistryKeyIfMissing -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 0
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
    }

    It 'Should handle Set-ItemProperty failure' {
        Mock Set-ItemProperty { throw $TestException }

        { Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent } | Should -Throw

        Should -Invoke New-RegistryKeyIfMissing -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 0
    }

    It 'Should handle Start-DownloadUnzipAndRun failure' {
        Mock Start-DownloadUnzipAndRun { throw $TestException }

        { Install-Unchecky -Execute:$TestExecute -Silent:$TestSilent } | Should -Throw

        Should -Invoke New-RegistryKeyIfMissing -Exactly 1
        Should -Invoke Set-ItemProperty -Exactly 1
        Should -Invoke Start-DownloadUnzipAndRun -Exactly 1
    }
}
