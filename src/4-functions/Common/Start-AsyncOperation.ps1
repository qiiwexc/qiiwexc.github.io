Set-Variable -Scope Script -Name ASYNC -Value ([Hashtable]@{
        Running         = $False
        Button          = $Null
        OriginalContent = $Null
        OnComplete      = $Null
        PS              = $Null
        Handle          = $Null
        Runspace        = $Null
        Timer           = $Null
    })

Set-Variable -Scope Script -Name ASYNC_USER_FUNCTIONS -Value $Null

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

    if ($Button) {
        $script:ASYNC.OriginalContent = $Button.Content

        $Button.Content = "$(ConvertTo-Emoji '274C') Cancel"
        $Button.Resources['AccentColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(196, 43, 28))
        $Button.Resources['AccentHoverColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(218, 59, 43))
        $Button.Resources['AccentPressedColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(172, 38, 24))
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
        $script:ASYNC.Button.Resources.Remove('AccentColor')
        $script:ASYNC.Button.Resources.Remove('AccentHoverColor')
        $script:ASYNC.Button.Resources.Remove('AccentPressedColor')
    }

    Set-Icon ([IconName]::Default)

    Set-Variable -Option Constant OnComplete ([ScriptBlock]$script:ASYNC.OnComplete)

    $script:ASYNC.Running = $False
    $script:ASYNC.Button = $Null
    $script:ASYNC.OriginalContent = $Null
    $script:ASYNC.OnComplete = $Null
    $script:ASYNC.PS = $Null
    $script:ASYNC.Handle = $Null
    $script:ASYNC.Runspace = $Null
    $script:ASYNC.Timer = $Null

    if ($OnComplete -and $State -eq 'Completed') {
        & $OnComplete $Output
    }
}


function Stop-AsyncOperation {
    if ($script:ASYNC.Running -and $script:ASYNC.PS) {
        Write-LogWarning 'Cancelling operation...'
        $script:ASYNC.PS.Stop()
    }
}
