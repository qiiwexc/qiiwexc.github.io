BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\Invoke-CustomCommand.ps1'
    . '.\src\4-functions\Common\Network.ps1'
    . '.\src\4-functions\Common\New-Directory.ps1'
    . '.\src\4-functions\Configuration\Windows\Tools\Assertions.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestCommand ([String]'& ([ScriptBlock]::Create((irm "https://christitus.com/win")))')
}

Describe 'Start-WinUtil' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Test-NetworkConnection { return $True }
        Mock Invoke-CustomCommand {}
        Mock Out-Success {}
        Mock Out-Failure {}
    }

    It 'Should start WinUtil with configuration' {
        Start-WinUtil

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1 -ParameterFilter { $Command -eq $TestCommand }
        Should -Invoke Out-Success -Exactly 1
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should exit if no network connection' {
        Mock Test-NetworkConnection { return $False }

        Start-WinUtil

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 0
    }

    It 'Should handle Test-NetworkConnection failure' {
        Mock Test-NetworkConnection { throw $TestException }

        Start-WinUtil

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 0
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }

    It 'Should handle Invoke-CustomCommand failure' {
        Mock Invoke-CustomCommand { throw $TestException }

        Start-WinUtil

        Should -Invoke Test-NetworkConnection -Exactly 1
        Should -Invoke Invoke-CustomCommand -Exactly 1
        Should -Invoke Out-Success -Exactly 0
        Should -Invoke Out-Failure -Exactly 1
    }
}
