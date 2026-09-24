BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    . "$PSScriptRoot\..\Common\types.ps1"
    . "$PSScriptRoot\..\Common\Remove-Directory.ps1"
    . "$PSScriptRoot\..\Common\Start-AsyncOperation.ps1"
    . "$PSScriptRoot\Exit.ps1"
    . "$PSScriptRoot\Initialize-AppDirectory.ps1"
    . "$PSScriptRoot\Logger.ps1"

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant PATH_OOSHUTUP10 ([String]'TEST_OOSHUTUP10')
    Set-Variable -Option Constant PATH_APP_DIR ([String]'TEST_APP_DIR')

    Set-Variable -Option Constant TestDate ([String]'TEST_DATE')
}

Describe 'Initialize-App' {
    BeforeAll {
        function Activate {}
        function ToString {}

        Mock Activate {}
        Mock ToString { return $TestDate }
        Mock Get-Date { return ToString }
        Mock Write-FormLog {}
        Mock Remove-Directory {}
        Mock Initialize-AppDirectory {}
        Mock Start-AsyncOperation {}
        Mock Exit-App {}
    }

    BeforeEach {
        [Windows.Window]$FORM = New-MockObject -Type Windows.Window -Methods @{ Activate = { Activate } }

        [Bool]$DevMode = $False
    }

    It 'Should initialize the application' {
        Initialize-App

        Should -Invoke Activate -Exactly 1
        Should -Invoke Get-Date -Exactly 1
        Should -Invoke ToString -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
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
        Should -Invoke Start-AsyncOperation -Exactly 1
        Should -Invoke Start-AsyncOperation -Exactly 1 -ParameterFilter {
            $Operation.ToString() -match 'Get-SystemInformation' -and
            $Operation.ToString() -match 'Update-App' -and
            $Variables.DevMode -eq $False -and
            $OnComplete -and
            -not $Button
        }
        Should -Invoke Exit-App -Exactly 0
    }

    It 'Should exit once the new version has been started' {
        Mock Start-AsyncOperation { & $OnComplete @($True) }

        Initialize-App

        Should -Invoke Exit-App -Exactly 1
        Should -Invoke Exit-App -Exactly 1 -ParameterFilter { $Update -eq $True }
    }

    It 'Should keep running when no new version has been started' {
        Mock Start-AsyncOperation { & $OnComplete @($False) }

        Initialize-App

        Should -Invoke Exit-App -Exactly 0
    }

    It 'Should handle Remove-Directory failure' {
        Mock Remove-Directory { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Activate -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Remove-Directory -Exactly 1
        Should -Invoke Initialize-AppDirectory -Exactly 0
        Should -Invoke Start-AsyncOperation -Exactly 0
    }

    It 'Should handle Initialize-AppDirectory failure' {
        Mock Initialize-AppDirectory { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Activate -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Remove-Directory -Exactly 2
        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-AsyncOperation -Exactly 0
    }

    It 'Should handle Start-AsyncOperation failure' {
        Mock Start-AsyncOperation { throw $TestException }

        { Initialize-App } | Should -Throw $TestException

        Should -Invoke Initialize-AppDirectory -Exactly 1
        Should -Invoke Start-AsyncOperation -Exactly 1
        Should -Invoke Exit-App -Exactly 0
    }
}
