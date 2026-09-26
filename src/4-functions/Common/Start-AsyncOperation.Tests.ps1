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

    # Stands in for a button, whose IsEnabled is all the button state reads and writes
    function New-TestButton {
        param(
            [Bool]$Enabled = $True
        )

        return [PSCustomObject]@{ IsEnabled = $Enabled }
    }
}

Describe 'Cancel button colours' {
    BeforeAll {
        . "$PSScriptRoot\..\..\0-init\5 Theme.ps1"
    }

    It 'Should override only resources that the theme gives buttons, so none is left in the theme colour' {
        [String[]]$ThemeKeys = @((Get-ThemeColors -Light).Keys)

        @($CANCEL_BUTTON_COLORS.Keys | Where-Object { $_ -notin $ThemeKeys }) | Should -BeNullOrEmpty
        @($ThemeKeys | Where-Object { $_ -like 'Button*' -and $_ -notlike '*Disabled*' -and $_ -notin $CANCEL_BUTTON_COLORS.Keys }) | Should -BeNullOrEmpty
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
            Cancelling      = $False
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
        Mock Start-ProgressBarReset {}
    }

    BeforeEach {
        Set-Variable -Option Constant MockTimer ([PSCustomObject]@{})
        $MockTimer | Add-Member -MemberType ScriptMethod -Name Stop -Value {}
        Set-Variable -Option Constant MockRunspace ([PSCustomObject]@{})
        $MockRunspace | Add-Member -MemberType ScriptMethod -Name Dispose -Value {}

        $script:ASYNC = @{
            Running         = $True
            Cancelling      = $False
            Button          = $Null
            OriginalContent = $Null
            OnComplete      = $Null
            PS              = (New-TestAsyncPS -State 'Completed' -Output @($True))
            Handle          = [PSCustomObject]@{ IsCompleted = $True }
            Runspace        = $MockRunspace
            Timer           = $MockTimer
        }

        $script:ASYNC_BUTTONS = [Collections.Generic.Dictionary[Object, Bool]]::new()

        [Collections.Generic.List[Object]]$script:CompletionOutput = @()
    }

    It 'Should restore every button to its own state for a <State> operation' -ForEach @(
        @{ State = 'Completed' }
        @{ State = 'Failed' }
        @{ State = 'Stopped' }
    ) {
        $script:ASYNC.PS = New-TestAsyncPS -State $State -Reason ([Exception]::new('TEST_FAILURE'))
        $script:ASYNC.Cancelling = $State -eq 'Stopped'
        Set-Variable -Option Constant Available (New-TestButton -Enabled $False)
        Set-Variable -Option Constant Unavailable (New-TestButton -Enabled $False)
        $script:ASYNC_BUTTONS[$Available] = $True
        $script:ASYNC_BUTTONS[$Unavailable] = $False

        Complete-AsyncOperation

        $Available.IsEnabled | Should -BeTrue
        $Unavailable.IsEnabled | Should -BeFalse
        $script:ASYNC.Cancelling | Should -BeFalse
    }

    It 'Should turn the button that cancels the operation back into the one that started it' {
        [Hashtable]$Resources = @{ UNRELATED_RESOURCE = 'KEPT' }
        foreach ($Key in $CANCEL_BUTTON_COLORS.Keys) {
            $Resources[$Key] = 'CANCEL_COLOR'
        }
        $script:ASYNC.Button = [PSCustomObject]@{ Content = 'CANCEL'; Resources = $Resources }
        $script:ASYNC.OriginalContent = 'ORIGINAL_CONTENT'
        Set-Variable -Option Constant Button ([PSCustomObject]$script:ASYNC.Button)

        Complete-AsyncOperation

        $Button.Content | Should -BeExactly 'ORIGINAL_CONTENT'
        @($Button.Resources.Keys) | Should -BeExactly @('UNRELATED_RESOURCE')
    }

    It 'Should empty the progress bar a moment after a <State> operation' -ForEach @(
        @{ State = 'Completed' }
        @{ State = 'Failed' }
        @{ State = 'Stopped' }
    ) {
        $script:ASYNC.PS = New-TestAsyncPS -State $State -Reason ([Exception]::new('TEST_FAILURE'))

        Complete-AsyncOperation

        Should -Invoke Start-ProgressBarReset -Exactly 1
    }

    It 'Should restore the buttons before the completion handler runs' {
        Set-Variable -Option Constant Button (New-TestButton -Enabled $False)
        $script:ASYNC_BUTTONS[$Button] = $True
        $script:ASYNC.OnComplete = { param($Output) $script:CompletionOutput.Add($Button.IsEnabled) }

        Complete-AsyncOperation

        $script:CompletionOutput | Should -BeExactly @($True)
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
        # Records each stop request, and fails a synchronous Stop(), which would block the UI thread
        Set-Variable -Option Constant MockPS ([PSCustomObject]@{ StopRequests = 0 })
        $MockPS | Add-Member -MemberType ScriptMethod -Name BeginStop -Value { param($Callback, $State) $this.StopRequests++ }
        $MockPS | Add-Member -MemberType ScriptMethod -Name Stop -Value { throw 'Stop() waits for the operation' }

        $script:ASYNC = @{
            Running         = $False
            Cancelling      = $False
            Button          = $Null
            OriginalContent = $Null
            PS              = $Null
            Handle          = $Null
            Runspace        = $Null
            Timer           = $Null
        }

        $script:ASYNC_BUTTONS = [Collections.Generic.Dictionary[Object, Bool]]::new()
    }

    It 'Should stop operation when running' {
        Set-Variable -Option Constant Button (New-TestButton)
        $script:ASYNC_BUTTONS[$Button] = $True
        $script:ASYNC.Running = $True
        $script:ASYNC.Button = $Button
        $script:ASYNC.PS = $MockPS

        Stop-AsyncOperation

        $MockPS.StopRequests | Should -BeExactly 1
        $script:ASYNC.Cancelling | Should -BeTrue
        $Button.IsEnabled | Should -BeFalse
        Should -Invoke Write-LogWarning -Exactly 1
        Should -Invoke Write-LogWarning -Exactly 1 -ParameterFilter {
            $Message -eq 'Cancelling operation...'
        }
    }

    It 'Should not stop an operation that is already cancelling' {
        $script:ASYNC.Running = $True
        $script:ASYNC.Cancelling = $True
        $script:ASYNC.PS = $MockPS

        Stop-AsyncOperation

        $MockPS.StopRequests | Should -BeExactly 0
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should not stop when no operation is running' {
        Stop-AsyncOperation

        $script:ASYNC.Cancelling | Should -BeFalse
        Should -Invoke Write-LogWarning -Exactly 0
    }

    It 'Should not stop when PowerShell instance is null' {
        $script:ASYNC.Running = $True
        $script:ASYNC.PS = $Null

        Stop-AsyncOperation

        $script:ASYNC.Cancelling | Should -BeFalse
        Should -Invoke Write-LogWarning -Exactly 0
    }
}

Describe 'Register-AsyncButton' {
    BeforeEach {
        $script:ASYNC_BUTTONS = [Collections.Generic.Dictionary[Object, Bool]]::new()
    }

    It 'Should keep the state a button is rendered with' {
        Set-Variable -Option Constant Enabled (New-TestButton)
        Set-Variable -Option Constant Disabled (New-TestButton -Enabled $False)

        Register-AsyncButton $Enabled
        Register-AsyncButton $Disabled

        $script:ASYNC_BUTTONS.Count | Should -BeExactly 2
        $script:ASYNC_BUTTONS[$Enabled] | Should -BeTrue
        $script:ASYNC_BUTTONS[$Disabled] | Should -BeFalse
    }
}

Describe 'Set-ButtonEnabled' {
    BeforeEach {
        $script:ASYNC = @{
            Running    = $False
            Cancelling = $False
            Button     = $Null
        }

        $script:ASYNC_BUTTONS = [Collections.Generic.Dictionary[Object, Bool]]::new()
    }

    It 'Should set a button that starts no operation at once, whatever is running' {
        Set-Variable -Option Constant Button (New-TestButton)
        $script:ASYNC.Running = $True

        Set-ButtonEnabled $Button $False

        $Button.IsEnabled | Should -BeFalse

        Set-ButtonEnabled $Button $True

        $Button.IsEnabled | Should -BeTrue
        $script:ASYNC_BUTTONS.Count | Should -BeExactly 0
    }

    It 'Should set a button that starts an operation at once when no operation is running' {
        Set-Variable -Option Constant Button (New-TestButton)
        $script:ASYNC_BUTTONS[$Button] = $True

        Set-ButtonEnabled $Button $False

        $Button.IsEnabled | Should -BeFalse
        $script:ASYNC_BUTTONS[$Button] | Should -BeFalse
    }

    It 'Should keep a button that starts an operation disabled until no operation is running' {
        Set-Variable -Option Constant Button (New-TestButton -Enabled $False)
        $script:ASYNC_BUTTONS[$Button] = $False
        $script:ASYNC.Running = $True

        Set-ButtonEnabled $Button $True

        $Button.IsEnabled | Should -BeFalse
        $script:ASYNC_BUTTONS[$Button] | Should -BeTrue
    }

    It 'Should keep the running button enabled, to cancel its operation' {
        Set-Variable -Option Constant Button (New-TestButton)
        $script:ASYNC_BUTTONS[$Button] = $True
        $script:ASYNC.Running = $True
        $script:ASYNC.Button = $Button

        Set-ButtonEnabled $Button $False

        $Button.IsEnabled | Should -BeTrue
        $script:ASYNC_BUTTONS[$Button] | Should -BeFalse
    }
}

Describe 'Update-AsyncButtonState' {
    BeforeEach {
        $script:ASYNC = @{
            Running    = $True
            Cancelling = $False
            Button     = $Null
        }

        $script:ASYNC_BUTTONS = [Collections.Generic.Dictionary[Object, Bool]]::new()

        Set-Variable -Option Constant Running (New-TestButton)
        Set-Variable -Option Constant Available (New-TestButton)
        Set-Variable -Option Constant Unavailable (New-TestButton -Enabled $False)
        $script:ASYNC_BUTTONS[$Running] = $True
        $script:ASYNC_BUTTONS[$Available] = $True
        $script:ASYNC_BUTTONS[$Unavailable] = $False
    }

    It 'Should disable every button but the one that cancels the running operation' {
        $script:ASYNC.Button = $Running

        Update-AsyncButtonState

        $Running.IsEnabled | Should -BeTrue
        $Available.IsEnabled | Should -BeFalse
        $Unavailable.IsEnabled | Should -BeFalse
    }

    It 'Should disable every button while an operation without a button runs' {
        Update-AsyncButtonState

        $Running.IsEnabled | Should -BeFalse
        $Available.IsEnabled | Should -BeFalse
        $Unavailable.IsEnabled | Should -BeFalse
    }

    It 'Should disable every button while the running operation is cancelling' {
        $script:ASYNC.Button = $Running
        $script:ASYNC.Cancelling = $True

        Update-AsyncButtonState

        $Running.IsEnabled | Should -BeFalse
        $Available.IsEnabled | Should -BeFalse
    }

    It 'Should restore every button to its own state when no operation is running' {
        $script:ASYNC.Running = $False
        $Running.IsEnabled = $False
        $Available.IsEnabled = $False
        $Unavailable.IsEnabled = $True

        Update-AsyncButtonState

        $Running.IsEnabled | Should -BeTrue
        $Available.IsEnabled | Should -BeTrue
        $Unavailable.IsEnabled | Should -BeFalse
    }
}
