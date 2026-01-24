BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    . '.\src\4-functions\Common\Get-SystemInformation.ps1'
    . '.\src\4-functions\Common\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Remove-Directory.ps1'
    . '.\src\4-functions\Common\Updater.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_WINUTIL ([String]'TEST_WINUTIL')
    Set-Variable -Option Constant PATH_OOSHUTUP10 ([String]'TEST_OOSHUTUP10')
    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_APP_DIR')

    Set-Variable -Option Constant TestDate ([String]'TEST_DATE')
}

Describe 'Initialize-App' {
    BeforeAll {
        function Activate {}
        function ToString {}
    }

    BeforeEach {
        Mock Activate {}
        Mock ToString { return $TestDate }
        Mock Get-Date { return ToString }
        Mock Write-FormLog {}
        Mock Write-LogWarning {}
        Mock Add-Type {}
        Mock Set-Variable {}
        Mock Get-SystemInformation {}
        Mock Remove-Directory {}
        Mock Initialize-AppDirectory {}
        Mock Update-App {}

        [Windows.Forms.Form]$FORM = New-MockObject -Type Windows.Forms.Form -Methods @{ Activate = { Activate } }
        [Int]$OS_VERSION = 11
    }

    It 'Should initialize the application' {
        Initialize-App

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Add-Type -Exactly 1
        Should -Invoke Add-Type -Exactly 1 -ParameterFilter { $AssemblyName -eq 'System.IO.Compression.FileSystem' }
        Should -Invoke Set-Variable -Exactly 1
        Should -Invoke Set-Variable -Exactly 1 -ParameterFilter {
            $Option -eq 'Constant' -and
            $Scope -eq 'Script' -and
            $Name -eq 'ZIP_SUPPORTED' -and
            $Value -eq $True
        }
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter {
            $DirectoryPath -eq $PATH_WINUTIL -and
            $Silent -eq $True
        }
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter {
            $DirectoryPath -eq $PATH_OOSHUTUP10 -and
            $Silent -eq $True
        }
        Should -Invoke Remove-Directory -Exactly 1 -ParameterFilter {
            $DirectoryPath -eq $PATH_APP_DIR -and
            $Silent -eq $True
        }
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Update-App -Exactly 1
    }

    It 'Should initialize the application with unsupported OS version' {
        [Int]$OS_VERSION = 7

        Initialize-App

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Add-Type -Exactly 1
        Should -Invoke Set-Variable -Exactly 1
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Update-App -Exactly 1
    }

    It 'Should handle Add-Type failure' {
        Mock Add-Type { throw $TestException }

        Initialize-App

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Add-Type -Exactly 1
        Should -Invoke Set-Variable -Exactly 0
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Update-App -Exactly 1
    }

    It 'Should handle Get-SystemInformation failure' {
        Mock Get-SystemInformation { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Add-Type -Exactly 1
        Should -Invoke Set-Variable -Exactly 1
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 0
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Update-App -Exactly 0
    }

    It 'Should handle Remove-Directory failure' {
        Mock Remove-Directory { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Add-Type -Exactly 1
        Should -Invoke Set-Variable -Exactly 1
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Update-App -Exactly 0
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Add-Type -Exactly 1
        Should -Invoke Set-Variable -Exactly 1
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Update-App -Exactly 0
    }

    It 'Should handle Update-App failure' {
        Mock Update-App { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
        Should -Invoke Add-Type -Exactly 1
        Should -Invoke Set-Variable -Exactly 1
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 3
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Update-App -Exactly 1
    }
}
