Set-Variable -Scope Script -Name ASYNC -Value ([Hashtable]@{
        Running         = $False
        Button          = $Null
        OriginalContent = $Null
        PS              = $Null
        Handle          = $Null
        Runspace        = $Null
        Timer           = $Null
    })

Set-Variable -Scope Script -Name ASYNC_USER_FUNCTIONS -Value $Null

function Start-AsyncOperation {
    param(
        [Parameter(Position = 0, Mandatory)][ScriptBlock]$Operation,
        [Object]$Button,
        [Hashtable]$Variables = @{}
    )

    if ($script:ASYNC.Running) {
        if ($Button -eq $script:ASYNC.Button) {
            Stop-AsyncOperation
        } else {
            Write-LogWarning 'An operation is already in progress'
        }
        return
    }

    $script:ASYNC.Running = $True
    $script:ASYNC.Button = $Button
    $script:ASYNC.OriginalContent = $Button.Content

    $Button.Content = "$(ConvertTo-Emoji '274C') Cancel"
    $Button.Resources['AccentColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(196, 43, 28))
    $Button.Resources['AccentHoverColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(218, 59, 43))
    $Button.Resources['AccentPressedColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(172, 38, 24))

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

    foreach ($PathVar in @('PATH_WORKING_DIR', 'PATH_TEMP_DIR', 'PATH_SYSTEM_32', 'PATH_APP_DIR',
            'PATH_7ZIP_EXE', 'PATH_OFFICE_C2R_CLIENT_EXE', 'PATH_OOSHUTUP10')) {
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
    [void]$script:ASYNC.PS.AddScript($Operation)

    $script:ASYNC.Handle = $script:ASYNC.PS.BeginInvoke()

    $script:ASYNC.Timer = New-Object Windows.Threading.DispatcherTimer
    $script:ASYNC.Timer.Interval = [TimeSpan]::FromMilliseconds(100)
    $script:ASYNC.Timer.Add_Tick(
        {
            # Use index-based access — PSDataCollection's foreach enumerator blocks
            # waiting for new items while the collection is open, which freezes the UI
            for ($i = 0; $i -lt $script:ASYNC.PS.Streams.Information.Count; $i++) {
                Write-Host $script:ASYNC.PS.Streams.Information[$i].MessageData
            }
            if ($script:ASYNC.PS.Streams.Information.Count -gt 0) { $script:ASYNC.PS.Streams.Information.Clear() }

            for ($i = 0; $i -lt $script:ASYNC.PS.Streams.Warning.Count; $i++) {
                Write-Host "WARNING: $($script:ASYNC.PS.Streams.Warning[$i].Message)" -ForegroundColor Yellow
            }
            if ($script:ASYNC.PS.Streams.Warning.Count -gt 0) { $script:ASYNC.PS.Streams.Warning.Clear() }

            for ($i = 0; $i -lt $script:ASYNC.PS.Streams.Error.Count; $i++) {
                Write-Host "ERROR: $($script:ASYNC.PS.Streams.Error[$i].Exception.Message)" -ForegroundColor Red
            }
            if ($script:ASYNC.PS.Streams.Error.Count -gt 0) { $script:ASYNC.PS.Streams.Error.Clear() }

            if ($script:ASYNC.Handle.IsCompleted) {
                $script:ASYNC.Timer.Stop()

                if ($script:ASYNC.PS.InvocationStateInfo.State -eq 'Stopped') {
                    Write-LogInfo 'Operation cancelled'
                    Invoke-WriteProgress -Id 1 -Activity 'Cancelled' -Completed
                } elseif ($script:ASYNC.PS.InvocationStateInfo.State -eq 'Failed') {
                    Write-LogError "Operation failed: $($script:ASYNC.PS.InvocationStateInfo.Reason.Message)"
                }

                if ($script:ASYNC.PS.InvocationStateInfo.State -ne 'Stopped') {
                    try { $script:ASYNC.PS.EndInvoke($script:ASYNC.Handle) } catch {
                        Write-LogError "Async operation error: $($_.Exception.Message)"
                    }
                }

                $script:ASYNC.PS.Dispose()
                $script:ASYNC.Runspace.Dispose()

                $script:ASYNC.Button.Content = $script:ASYNC.OriginalContent
                $script:ASYNC.Button.Resources.Remove('AccentColor')
                $script:ASYNC.Button.Resources.Remove('AccentHoverColor')
                $script:ASYNC.Button.Resources.Remove('AccentPressedColor')

                Set-Icon ([IconName]::Default)

                $script:ASYNC.Running = $False
                $script:ASYNC.Button = $Null
                $script:ASYNC.OriginalContent = $Null
                $script:ASYNC.PS = $Null
                $script:ASYNC.Handle = $Null
                $script:ASYNC.Runspace = $Null
                $script:ASYNC.Timer = $Null
            }
        }
    )
    $script:ASYNC.Timer.Start()
}


function Stop-AsyncOperation {
    if ($script:ASYNC.Running -and $script:ASYNC.PS) {
        Write-LogWarning 'Cancelling operation...'
        $script:ASYNC.PS.Stop()
    }
}
