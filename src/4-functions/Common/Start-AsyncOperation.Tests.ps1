BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'
    . '.\src\4-functions\App lifecycle\Logger.ps1'
}

Describe 'Start-AsyncOperation' {
    BeforeEach {
        $script:ASYNC = @{
            Running         = $False
            Button          = $Null
            OriginalContent = $Null
            PS              = $Null
            Handle          = $Null
            Runspace        = $Null
            Timer           = $Null
        }

        Mock Write-LogWarning {}
        Mock Stop-AsyncOperation {}
    }

    It 'Should cancel when same button clicked while operation is running' {
        $script:ASYNC.Running = $True
        $script:ASYNC.Button = 'BUTTON_A'

        Start-AsyncOperation { } -Button 'BUTTON_A'

        Should -Invoke Stop-AsyncOperation -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should warn when different button clicked while operation is running' {
        $script:ASYNC.Running = $True
        $script:ASYNC.Button = 'BUTTON_A'

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
        $script:ASYNC = @{
            Running         = $False
            Button          = $Null
            OriginalContent = $Null
            PS              = $Null
            Handle          = $Null
            Runspace        = $Null
            Timer           = $Null
        }

        Mock Write-LogWarning {}
    }

    It 'Should stop operation when running' {
        $MockPS = [PSCustomObject]@{}
        $MockPS | Add-Member -MemberType ScriptMethod -Name Stop -Value {}
        $script:ASYNC.Running = $True
        $script:ASYNC.PS = $MockPS

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
        $script:ASYNC.Running = $True
        $script:ASYNC.PS = $Null

        Stop-AsyncOperation

        Should -Invoke Write-LogWarning -Exactly 0
    }
}
