BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName System.Windows.Forms

    . '.\src\4-functions\Common\types.ps1'
    . '.\src\4-functions\Common\Remove-Directory.ps1'
    . '.\src\4-functions\App lifecycle\Get-SystemInformation.ps1'
    . '.\src\4-functions\App lifecycle\Initialize-AppDirectory.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
    . '.\src\4-functions\App lifecycle\Updater.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

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
        Mock Get-SystemInformation {}
        Mock Remove-Directory {}
        Mock Initialize-AppDirectory {}
        Mock Update-App {}

        [Windows.Forms.Form]$FORM = New-MockObject -Type Windows.Forms.Form -Methods @{ Activate = { Activate } }
    }

    It 'Should initialize the application' {
        Initialize-App

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
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

    It 'Should handle Get-SystemInformation failure' {
        Mock Get-SystemInformation { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
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
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
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
        Should -Invoke Get-SystemInformation -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Update-App -Exactly 1
    }
}
