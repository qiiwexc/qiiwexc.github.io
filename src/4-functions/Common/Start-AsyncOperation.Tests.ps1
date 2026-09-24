BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\types.ps1"
    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"
    . "$PSScriptRoot\..\App lifecycle\Progressbar.ps1"
    . "$PSScriptRoot\..\App lifecycle\Set-Icon.ps1"

    # Real stream records, as an async runspace produces them — from the logger and from elsewhere
    Set-Variable -Option Constant TestStreams ([PowerShell]::Create())
    [Void]$TestStreams.AddScript({
            function Write-LogWarning { Write-Warning 'LOGGER_WARNING' }
            function Write-LogError { Write-Error 'LOGGER_ERROR' }
            Write-LogWarning
            Write-Warning 'OTHER_WARNING'
            Write-LogError
            Write-Error 'OTHER_ERROR'
        }).Invoke()

    function New-TestAsyncPS {
        param(
            [String]$State = 'Running',
            [Exception]$Reason,
            [Object[]]$Output = @()
        )

        Set-Variable -Option Constant Streams ([PSCustomObject]@{
                Information = [Collections.Generic.List[Management.Automation.InformationRecord]]::new()
                Warning     = [Collections.Generic.List[Management.Automation.WarningRecord]]::new()
                Error       = [Collections.Generic.List[Management.Automation.ErrorRecord]]::new()
            })
        Set-Variable -Option Constant MockPS ([PSCustomObject]@{
                Streams             = $Streams
                InvocationStateInfo = [PSCustomObject]@{ State = $State; Reason = $Reason }
            })
        $MockPS | Add-Member -MemberType ScriptMethod -Name EndInvoke -Value { param($Handle) return $Output }.GetNewClosure()
        $MockPS | Add-Member -MemberType ScriptMethod -Name Dispose -Value {}
        return $MockPS
    }
}

Describe 'Start-AsyncOperation' {
    BeforeAll {
        Mock Write-LogWarning {}
        Mock Stop-AsyncOperation {}
    }

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

    It 'Should not cancel an operation without a button when another one without a button starts' {
        $script:ASYNC.Running = $True
        $script:ASYNC.Button = $Null

        Start-AsyncOperation { }

        Should -Invoke Stop-AsyncOperation -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }

    It 'Should warn when a button is clicked while an operation without a button is running' {
        $script:ASYNC.Running = $True
        $script:ASYNC.Button = $Null

        Start-AsyncOperation { } -Button 'BUTTON_A'

        Should -Invoke Stop-AsyncOperation -Exactly 0
        Should -Invoke Write-LogWarning -Exactly 1
    }
}

Describe 'Test-LoggerRecord' {
    It 'Should recognise records written by the logger' {
        Test-LoggerRecord $TestStreams.Streams.Warning[0] | Should -BeTrue
        Test-LoggerRecord $TestStreams.Streams.Error[0] | Should -BeTrue
    }

    It 'Should not recognise records written elsewhere' {
        Test-LoggerRecord $TestStreams.Streams.Warning[1] | Should -BeFalse
        Test-LoggerRecord $TestStreams.Streams.Error[1] | Should -BeFalse
    }
}

Describe 'Update-AsyncOperationState' {
    BeforeAll {
        Mock Write-Host {}
        Mock Write-FormLog {}
        Mock Complete-AsyncOperation {}
    }

    BeforeEach {
        $script:ASYNC = @{
            Running = $True
            PS      = (New-TestAsyncPS)
            Handle  = [PSCustomObject]@{ IsCompleted = $False }
        }
    }

    It 'Should forward warnings and errors that did not come from the logger to the form log' {
        $TestStreams.Streams.Warning | ForEach-Object { $script:ASYNC.PS.Streams.Warning.Add($_) }
        $TestStreams.Streams.Error | ForEach-Object { $script:ASYNC.PS.Streams.Error.Add($_) }

        Update-AsyncOperationState

        Should -Invoke Write-Host -Exactly 4
        Should -Invoke Write-FormLog -Exactly 2
        Should -Invoke Write-FormLog -Exactly 1 -ParameterFilter { $Level -eq [LogLevel]::WARN -and $Message -match 'OTHER_WARNING' }
        Should -Invoke Write-FormLog -Exactly 1 -ParameterFilter { $Level -eq [LogLevel]::ERROR -and $Message -match 'OTHER_ERROR' }
        Should -Invoke Complete-AsyncOperation -Exactly 0

        $script:ASYNC.PS.Streams.Warning.Count | Should -Be 0
        $script:ASYNC.PS.Streams.Error.Count | Should -Be 0
    }

    It 'Should not forward the error that failed the operation' {
        Set-Variable -Option Constant FailureRecord ([Management.Automation.ErrorRecord]$TestStreams.Streams.Error[1])
        Set-Variable -Option Constant FailureReason ([Management.Automation.RuntimeException]::new('OTHER_ERROR', $Null, $FailureRecord))
        $script:ASYNC.PS = New-TestAsyncPS -State 'Failed' -Reason $FailureReason
        $script:ASYNC.PS.Streams.Error.Add($FailureRecord)
        $script:ASYNC.Handle = [PSCustomObject]@{ IsCompleted = $True }

        Update-AsyncOperationState

        Should -Invoke Write-FormLog -Exactly 0
        Should -Invoke Complete-AsyncOperation -Exactly 1
    }
}

Describe 'Complete-AsyncOperation' {
    BeforeAll {
        Mock Set-Icon {}
        Mock Write-LogInfo {}
        Mock Write-LogError {}
        Mock Invoke-WriteProgress {}
    }

    BeforeEach {
        Set-Variable -Option Constant MockTimer ([PSCustomObject]@{})
        $MockTimer | Add-Member -MemberType ScriptMethod -Name Stop -Value {}
        Set-Variable -Option Constant MockRunspace ([PSCustomObject]@{})
        $MockRunspace | Add-Member -MemberType ScriptMethod -Name Dispose -Value {}

        $script:ASYNC = @{
            Running         = $True
            Button          = $Null
            OriginalContent = $Null
            OnComplete      = $Null
            PS              = (New-TestAsyncPS -State 'Completed' -Output @($True))
            Handle          = [PSCustomObject]@{ IsCompleted = $True }
            Runspace        = $MockRunspace
            Timer           = $MockTimer
        }

        [Collections.Generic.List[Object]]$script:CompletionOutput = @()
    }

    It 'Should pass the operation output to the completion handler and reset the state' {
        $script:ASYNC.OnComplete = { param($Output) $script:CompletionOutput.AddRange([Object[]]$Output) }

        Complete-AsyncOperation

        $script:CompletionOutput | Should -HaveCount 1
        $script:CompletionOutput[0] | Should -BeTrue
        $script:ASYNC.Running | Should -BeFalse
        $script:ASYNC.OnComplete | Should -BeNullOrEmpty
        $script:ASYNC.PS | Should -BeNullOrEmpty
        Should -Invoke Write-LogError -Exactly 0
    }

    It 'Should not call the completion handler for a failed operation' {
        $script:ASYNC.PS = New-TestAsyncPS -State 'Failed' -Reason ([Exception]::new('TEST_FAILURE'))
        $script:ASYNC.OnComplete = { param($Output) $script:CompletionOutput.Add('CALLED') }

        Complete-AsyncOperation

        $script:CompletionOutput | Should -HaveCount 0
        $script:ASYNC.Running | Should -BeFalse
        Should -Invoke Write-LogError -Exactly 1
    }

    It 'Should not call the completion handler for a cancelled operation' {
        $script:ASYNC.PS = New-TestAsyncPS -State 'Stopped'
        $script:ASYNC.OnComplete = { param($Output) $script:CompletionOutput.Add('CALLED') }

        Complete-AsyncOperation

        $script:CompletionOutput | Should -HaveCount 0
        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Invoke-WriteProgress -Exactly 1
    }
}

Describe 'Stop-AsyncOperation' {
    BeforeAll {
        Mock Write-LogWarning {}
    }

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
