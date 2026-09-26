Set-Variable -Scope Script -Name ASYNC -Value ([Hashtable]@{
        Running         = $False
        Cancelling      = $False
        Button          = $Null
        OriginalContent = $Null
        OnComplete      = $Null
        PS              = $Null
        Handle          = $Null
        Runspace        = $Null
        Timer           = $Null
    })

Set-Variable -Scope Script -Name ASYNC_USER_FUNCTIONS -Value $Null

# Every button that starts an operation, with whether it is enabled when no operation is running
Set-Variable -Scope Script -Name ASYNC_BUTTONS -Value ([Collections.Generic.Dictionary[Object, Bool]]::new())

# The colours of the running operation's button, which cancels it: red with white text, whatever the theme
Set-Variable -Scope Script -Name CANCEL_BUTTON_COLORS -Value ([Hashtable]@{
        ButtonBgColor           = '#C42B1C'
        ButtonHoverColor        = '#DA3B2B'
        ButtonPressedColor      = '#AC2618'
        ButtonBorderColor       = '#C42B1C'
        ButtonBorderBottomColor = '#00000000'
        ButtonTextColor         = '#FFFFFF'
        ButtonPressedTextColor  = '#FFFFFF'
    })

# Operations without a button (such as the startup update check) cannot be cancelled.
# OnComplete runs on the UI thread with the operation's output once it completes successfully —
# use it for anything that must touch the window, which the async runspace cannot do safely.
function Start-AsyncOperation {
    param(
        [Parameter(Position = 0, Mandatory)][ScriptBlock]$Operation,
        [Object]$Button,
        [Hashtable]$Variables = @{},
        [ScriptBlock]$OnComplete
    )

    if ($script:ASYNC.Running) {
        if ($Button -and $Button -eq $script:ASYNC.Button) {
            Stop-AsyncOperation
        } else {
            Write-LogWarning 'An operation is already in progress'
        }
        return
    }

    $script:ASYNC.Running = $True
    $script:ASYNC.Button = $Button
    $script:ASYNC.OnComplete = $OnComplete

    Update-AsyncButtonState

    # From an empty progress bar, which a reset still pending from the last operation must not empty midway
    Reset-ProgressBar

    if ($Button) {
        $script:ASYNC.OriginalContent = $Button.Content

        $Button.Content = "$(ConvertTo-Emoji '274C') Cancel"
        Set-Variable -Option Constant Converter ([Windows.Media.BrushConverter]::new())
        foreach ($Entry in $script:CANCEL_BUTTON_COLORS.GetEnumerator()) {
            $Button.Resources[$Entry.Key] = $Converter.ConvertFromString($Entry.Value)
        }
    }

    Set-Icon ([IconName]::Working)

    [Management.Automation.Runspaces.InitialSessionState]$ISS = [Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

    # Copy user-defined functions into the new runspace so async operations can call
    # any function (logging, downloads, config, etc.) without maintaining a whitelist.
    # Built-in/default functions are excluded to reduce overhead.
    if ($Null -eq $script:ASYNC_USER_FUNCTIONS) {
        Set-Variable -Option Constant DefaultFunctions ([String[]]@(
                [Management.Automation.Runspaces.InitialSessionState]::CreateDefault().Commands |
                    Where-Object { $_ -is [Management.Automation.Runspaces.SessionStateFunctionEntry] } |
                    ForEach-Object { $_.Name }
            )
        )
        Set-Variable -Scope Script ASYNC_USER_FUNCTIONS @(Get-ChildItem Function: | Where-Object { $_.Name -notin $DefaultFunctions })
    }

    foreach ($Func in $script:ASYNC_USER_FUNCTIONS) {
        $ISS.Commands.Add(
            [Management.Automation.Runspaces.SessionStateFunctionEntry]::new(
                $Func.Name, $Func.ScriptBlock.ToString()
            )
        )
    }

    $script:ASYNC.Runspace = [runspacefactory]::CreateRunspace($ISS)
    $script:ASYNC.Runspace.ApartmentState = [Threading.ApartmentState]::STA
    $script:ASYNC.Runspace.Open()

    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('FORM', $FORM)
    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('PROGRESSBAR', $PROGRESSBAR)
    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('LOG', $LOG)
    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('LOG_BOX', $LOG_BOX)
    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('ACTIVITIES', [Collections.Stack]@())
    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('CURRENT_TASK', $Null)

    # The operation reaches the window only through this delegate, which this runspace created (Invoke-OnDispatcher)
    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('UI_THREAD_COMMAND', $UI_THREAD_COMMAND)

    # Propagate the UI thread's error preference so async operations fail the same way
    # synchronous code would; strict mode is enforced separately below.
    $script:ASYNC.Runspace.SessionStateProxy.SetVariable('ErrorActionPreference', $ErrorActionPreference)

    foreach ($PathVar in @('PATH_WORKING_DIR', 'PATH_TEMP_DIR', 'PATH_SYSTEM_32', 'PATH_APP_DIR',
            'PATH_OFFICE_C2R_CLIENT_EXE', 'PATH_OOSHUTUP10')) {
        try {
            $script:ASYNC.Runspace.SessionStateProxy.SetVariable($PathVar, (Get-Variable $PathVar -ValueOnly -ErrorAction SilentlyContinue))
        } catch { $null = $_ }
    }

    foreach ($SysVar in @('OS_VERSION', 'OS_64_BIT', 'OPERATING_SYSTEM', 'IS_LAPTOP', 'SYSTEM_LANGUAGE',
            'ICON_DEFAULT', 'ICON_WORKING', 'VERSION', 'AV_WARNINGS_SHOWN')) {
        try {
            $script:ASYNC.Runspace.SessionStateProxy.SetVariable($SysVar, (Get-Variable $SysVar -ValueOnly -ErrorAction SilentlyContinue))
        } catch { $null = $_ }
    }

    Get-Variable -Name 'CONFIG_*' -Scope Script -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $script:ASYNC.Runspace.SessionStateProxy.SetVariable($_.Name, $_.Value)
        } catch { $null = $_ }
    }

    foreach ($Entry in $Variables.GetEnumerator()) {
        $script:ASYNC.Runspace.SessionStateProxy.SetVariable($Entry.Key, $Entry.Value)
    }

    $script:ASYNC.PS = [PowerShell]::Create()
    $script:ASYNC.PS.Runspace = $script:ASYNC.Runspace

    # Enforce the same strict mode as the UI thread as its own statement, so a mistyped
    # variable or property fails loudly in async operations instead of passing silently.
    [void]$script:ASYNC.PS.AddScript({ Set-StrictMode -Version Latest })
    [void]$script:ASYNC.PS.AddStatement().AddScript($Operation)

    $script:ASYNC.Handle = $script:ASYNC.PS.BeginInvoke()

    $script:ASYNC.Timer = New-Object Windows.Threading.DispatcherTimer
    $script:ASYNC.Timer.Interval = [TimeSpan]::FromMilliseconds(100)
    $script:ASYNC.Timer.Add_Tick({ Update-AsyncOperationState })
    $script:ASYNC.Timer.Start()
}


function Update-AsyncOperationState {
    # Use index-based access — PSDataCollection's foreach enumerator blocks
    # waiting for new items while the collection is open, which freezes the UI
    for ($i = 0; $i -lt $script:ASYNC.PS.Streams.Information.Count; $i++) {
        Write-Host $script:ASYNC.PS.Streams.Information[$i].MessageData
    }
    if ($script:ASYNC.PS.Streams.Information.Count -gt 0) { $script:ASYNC.PS.Streams.Information.Clear() }

    # Write-LogWarning and Write-LogError already write to the form log — forward only records from
    # other sources, which would otherwise reach nothing but the console hidden outside dev mode
    for ($i = 0; $i -lt $script:ASYNC.PS.Streams.Warning.Count; $i++) {
        [Management.Automation.WarningRecord]$WarningRecord = $script:ASYNC.PS.Streams.Warning[$i]
        Write-Host "WARNING: $($WarningRecord.Message)" -ForegroundColor Yellow
        if (-not (Test-LoggerRecord $WarningRecord)) {
            Write-FormLog ([LogLevel]::WARN) (Format-Message ([LogLevel]::WARN) $WarningRecord.Message)
        }
    }
    if ($script:ASYNC.PS.Streams.Warning.Count -gt 0) { $script:ASYNC.PS.Streams.Warning.Clear() }

    # A failing operation also writes its terminating error to the error stream —
    # Complete-AsyncOperation reports that one, so it is not forwarded here
    Set-Variable -Option Constant FailureReason ([Exception]$script:ASYNC.PS.InvocationStateInfo.Reason)

    for ($i = 0; $i -lt $script:ASYNC.PS.Streams.Error.Count; $i++) {
        [Management.Automation.ErrorRecord]$ErrorRecord = $script:ASYNC.PS.Streams.Error[$i]
        Write-Host "ERROR: $($ErrorRecord.Exception.Message)" -ForegroundColor Red
        [Bool]$IsFailureReason = $FailureReason -is [Management.Automation.IContainsErrorRecord] -and [Object]::ReferenceEquals($ErrorRecord, $FailureReason.ErrorRecord)
        if (-not $IsFailureReason -and -not (Test-LoggerRecord $ErrorRecord)) {
            Write-FormLog ([LogLevel]::ERROR) (Format-Message ([LogLevel]::ERROR) $ErrorRecord.Exception.Message)
        }
    }
    if ($script:ASYNC.PS.Streams.Error.Count -gt 0) { $script:ASYNC.PS.Streams.Error.Clear() }

    if ($script:ASYNC.Handle.IsCompleted) {
        Complete-AsyncOperation
    }
}


function Test-LoggerRecord {
    param(
        [Parameter(Position = 0, Mandatory)][Object]$Record
    )

    Set-Variable -Option Constant Invocation ([Management.Automation.InvocationInfo]$Record.InvocationInfo)

    return [Bool]($Invocation -and $Invocation.MyCommand -and $Invocation.MyCommand.Name -in @('Write-LogWarning', 'Write-LogError'))
}


function Complete-AsyncOperation {
    $script:ASYNC.Timer.Stop()

    Set-Variable -Option Constant State ([Management.Automation.PSInvocationState]$script:ASYNC.PS.InvocationStateInfo.State)

    if ($State -eq 'Stopped') {
        Write-LogInfo 'Operation cancelled'
        Invoke-WriteProgress -Id 1 -Activity 'Cancelled' -Completed
    } elseif ($State -eq 'Failed') {
        Write-LogError "Operation failed: $($script:ASYNC.PS.InvocationStateInfo.Reason.Message)"
    }

    [PSObject[]]$Output = @()
    if ($State -ne 'Stopped') {
        try { $Output = @($script:ASYNC.PS.EndInvoke($script:ASYNC.Handle)) } catch {
            Write-LogError "Async operation error: $($_.Exception.Message)"
        }
    }

    $script:ASYNC.PS.Dispose()
    $script:ASYNC.Runspace.Dispose()

    if ($script:ASYNC.Button) {
        $script:ASYNC.Button.Content = $script:ASYNC.OriginalContent
        foreach ($Key in $script:CANCEL_BUTTON_COLORS.Keys) {
            $script:ASYNC.Button.Resources.Remove($Key)
        }
    }

    Set-Icon ([IconName]::Default)

    # Completed, failed or cancelled, the progress bar shows how it ended for a moment, then empties
    Start-ProgressBarReset

    Set-Variable -Option Constant OnComplete ([ScriptBlock]$script:ASYNC.OnComplete)

    $script:ASYNC.Running = $False
    $script:ASYNC.Cancelling = $False
    $script:ASYNC.Button = $Null
    $script:ASYNC.OriginalContent = $Null
    $script:ASYNC.OnComplete = $Null
    $script:ASYNC.PS = $Null
    $script:ASYNC.Handle = $Null
    $script:ASYNC.Runspace = $Null
    $script:ASYNC.Timer = $Null

    Update-AsyncButtonState

    if ($OnComplete -and $State -eq 'Completed') {
        & $OnComplete $Output
    }
}


function Stop-AsyncOperation {
    if ($script:ASYNC.Running -and $script:ASYNC.PS -and -not $script:ASYNC.Cancelling) {
        Write-LogWarning 'Cancelling operation...'

        $script:ASYNC.Cancelling = $True
        Update-AsyncButtonState

        # Without waiting: the operation may itself be waiting for the UI thread (Invoke-OnDispatcher), or be in a call
        # it cannot be stopped in. The timer completes it once it has stopped
        [Void]$script:ASYNC.PS.BeginStop($Null, $Null)
    }
}


# A button that starts an operation is disabled while another one runs, so a click is never turned away. The
# running operation's own button stays enabled, as the one that cancels it, until it is cancelling
function Register-AsyncButton {
    param(
        [Parameter(Position = 0, Mandatory)][Object]$Button
    )

    $script:ASYNC_BUTTONS[$Button] = $Button.IsEnabled
}


# Enables or disables a button for a reason of its own, such as having nothing selected to apply. A button
# that starts an operation keeps the state for when no operation is running, and takes it then
function Set-ButtonEnabled {
    param(
        [Parameter(Position = 0, Mandatory)][Object]$Button,
        [Parameter(Position = 1, Mandatory)][Bool]$Enabled
    )

    if ($script:ASYNC_BUTTONS.ContainsKey($Button)) {
        $script:ASYNC_BUTTONS[$Button] = $Enabled
        Update-AsyncButtonState
    } else {
        $Button.IsEnabled = $Enabled
    }
}


function Update-AsyncButtonState {
    foreach ($Entry in $script:ASYNC_BUTTONS.GetEnumerator()) {
        if ($script:ASYNC.Running) {
            $Entry.Key.IsEnabled = $Entry.Key -eq $script:ASYNC.Button -and -not $script:ASYNC.Cancelling
        } else {
            $Entry.Key.IsEnabled = $Entry.Value
        }
    }
}
