BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Logger.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
}

Describe 'Start-Activator' {
    BeforeEach {
        Mock Write-LogInfo { }
        Mock Test-NetworkConnection { return $True }
        Mock Invoke-CustomCommand { }
        Mock Out-Success { }

        [Switch]$TestActivateWindowsArg = $False
        [Switch]$TestActivateOfficeArg = $False

        [Int]$OS_VERSION = 11
    }

    It 'Should start MAS activator' {
        Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $Command -eq '& ([ScriptBlock]::Create((irm https://get.activated.win)))' -and
            $HideWindow -eq $True
        }
    }

    It 'Should start MAS activator successfully on Windows 7' {
        $OS_VERSION = 7

        Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $Command -eq "& ([ScriptBlock]::Create((New-Object Net.WebClient).DownloadString('https://get.activated.win')))" -and
            $HideWindow -eq $True
        }
    }

    It 'Should automatically activate Windows' {
        $TestActivateWindowsArg = $True

        Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $Command -match '\)\)\) /HWID' -and
            $HideWindow -eq $True
        }
    }

    It 'Should automatically activate Office' {
        $TestActivateOfficeArg = $True

        Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $Command -match '\)\)\) /Ohook' -and
            $HideWindow -eq $True
        }
    }

    It 'Should automatically activate both Windows and Office' {
        $TestActivateWindowsArg = $True
        $TestActivateOfficeArg = $True

        Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter {
            $Command -match '\)\)\) /HWID /Ohook' -and
            $HideWindow -eq $True
        }
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        { Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 0
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        { Start-Activator -ActivateWindows:$TestActivateWindowsArg -ActivateOffice:$TestActivateOfficeArg } | Should -Throw $TestException

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
    }
}
