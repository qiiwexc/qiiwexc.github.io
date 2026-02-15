BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
}

Describe 'Start-AsyncOperation' {
    BeforeEach {
        $script:ASYNC_OPERATION_RUNNING = $False
        $script:ASYNC_BUTTON = $Null
        $script:ASYNC_ORIGINAL_CONTENT = $Null
        $script:ASYNC_PS = $Null
        $script:ASYNC_HANDLE = $Null
        $script:ASYNC_RUNSPACE = $Null
        $script:ASYNC_TIMER = $Null

        Mock Write-LogWarning {}
        Mock Stop-AsyncOperation {}
    }

    It 'Should cancel when same button clicked while operation is running' {
        $script:ASYNC_OPERATION_RUNNING = $True
        $script:ASYNC_BUTTON = 'BUTTON_A'

        Start-AsyncOperation { } -Button 'BUTTON_A'

        Should -Invoke Stop-AsyncOperation -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should warn when different button clicked while operation is running' {
        $script:ASYNC_OPERATION_RUNNING = $True
        $script:ASYNC_BUTTON = 'BUTTON_A'

        Start-AsyncOperation { } -Button 'BUTTON_B'

        Should -Invoke Stop-AsyncOperation -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter {
            $Message -eq 'An operation is already in progress'
        }
    }
}

Describe 'Stop-AsyncOperation' {
    BeforeEach {
        $script:ASYNC_OPERATION_RUNNING = $False
        $script:ASYNC_PS = $Null

        Mock Write-LogWarning {}
    }

    It 'Should stop operation when running' {
        $MockPS = [PSCustomObject]@{}
        $MockPS | Add-Member -MemberType ScriptMethod -Name Stop -Value {}
        $script:ASYNC_OPERATION_RUNNING = $True
        $script:ASYNC_PS = $MockPS

        Stop-AsyncOperation

        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter {
            $Message -eq 'Cancelling operation...'
        }
    }

    It 'Should not stop when no operation is running' {
        Stop-AsyncOperation

        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should not stop when PowerShell instance is null' {
        $script:ASYNC_OPERATION_RUNNING = $True
        $script:ASYNC_PS = $Null

        Stop-AsyncOperation

        Should -Invoke Write-LogWarning -Exactly 0
    }
}
