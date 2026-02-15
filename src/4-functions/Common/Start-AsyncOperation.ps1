Set-Variable -Scope Script -Name ASYNC_OPERATION_RUNNING -Value $False
Set-Variable -Scope Script -Name ASYNC_BUTTON -Value $Null
Set-Variable -Scope Script -Name ASYNC_ORIGINAL_CONTENT -Value $Null
Set-Variable -Scope Script -Name ASYNC_PS -Value $Null
Set-Variable -Scope Script -Name ASYNC_HANDLE -Value $Null
Set-Variable -Scope Script -Name ASYNC_RUNSPACE -Value $Null
Set-Variable -Scope Script -Name ASYNC_TIMER -Value $Null

function Start-AsyncOperation {
    param(
        [ScriptBlock][Parameter(Position = 0, Mandatory)]$Operation,
        [Object]$Sender,
        [Hashtable]$Variables = @{}
    )

    if ($script:ASYNC_OPERATION_RUNNING) {
        if ($Sender -eq $script:ASYNC_BUTTON) {
            Stop-AsyncOperation
        } else {
            Write-LogWarning 'An operation is already in progress'
        }
        return
    }

    $script:ASYNC_OPERATION_RUNNING = $True
    $script:ASYNC_BUTTON = $Sender
    $script:ASYNC_ORIGINAL_CONTENT = $Sender.Content

    $Sender.Content = "$(Get-Emoji '274C') Cancel"
    $Sender.Resources['AccentColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(196, 43, 28))
    $Sender.Resources['AccentHoverColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(218, 59, 43))
    $Sender.Resources['AccentPressedColor'] = [Windows.Media.SolidColorBrush]::new([Windows.Media.Color]::FromRgb(172, 38, 24))

    Set-Icon ([IconName]::Working)

    [Management.Automation.Runspaces.InitialSessionState]$ISS = [Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

    foreach ($Func in (Get-ChildItem Function:)) {
        $ISS.Commands.Add(
            [Management.Automation.Runspaces.SessionStateFunctionEntry]::new(
                $Func.Name, $Func.ScriptBlock.ToString()
            )
        )
    }

    $script:ASYNC_RUNSPACE = [runspacefactory]::CreateRunspace($ISS)
    $script:ASYNC_RUNSPACE.ApartmentState = [Threading.ApartmentState]::STA
    $script:ASYNC_RUNSPACE.Open()

    $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable('FORM', $FORM)
    $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable('PROGRESSBAR', $PROGRESSBAR)
    $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable('LOG', $LOG)
    $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable('LOG_BOX', $LOG_BOX)
    $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable('ACTIVITIES', [Collections.Stack]@())
    $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable('CURRENT_TASK', $Null)

    foreach ($PathVar in @('PATH_WORKING_DIR', 'PATH_TEMP_DIR', 'PATH_SYSTEM_32', 'PATH_APP_DIR',
            'PATH_7ZIP_EXE', 'PATH_OFFICE_C2R_CLIENT_EXE', 'PATH_OOSHUTUP10')) {
        try {
            $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable($PathVar, (Get-Variable $PathVar -ValueOnly -ErrorAction SilentlyContinue))
        } catch {}
    }

    foreach ($SysVar in @('OS_VERSION', 'OS_64_BIT', 'OPERATING_SYSTEM', 'IS_LAPTOP', 'SYSTEM_LANGUAGE',
            'ICON_DEFAULT', 'ICON_WORKING', 'VERSION')) {
        try {
            $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable($SysVar, (Get-Variable $SysVar -ValueOnly -ErrorAction SilentlyContinue))
        } catch {}
    }

    Get-Variable -Name 'CONFIG_*' -Scope Script -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable($_.Name, $_.Value)
        } catch {}
    }

    foreach ($Entry in $Variables.GetEnumerator()) {
        $script:ASYNC_RUNSPACE.SessionStateProxy.SetVariable($Entry.Key, $Entry.Value)
    }

    $script:ASYNC_PS = [PowerShell]::Create()
    $script:ASYNC_PS.Runspace = $script:ASYNC_RUNSPACE
    [void]$script:ASYNC_PS.AddScript($Operation)

    $script:ASYNC_HANDLE = $script:ASYNC_PS.BeginInvoke()

    $script:ASYNC_TIMER = New-Object Windows.Threading.DispatcherTimer
    $script:ASYNC_TIMER.Interval = [TimeSpan]::FromMilliseconds(200)
    $script:ASYNC_TIMER.Add_Tick(
        {
            # Use index-based access — PSDataCollection's foreach enumerator blocks
            # waiting for new items while the collection is open, which freezes the UI
            for ($i = 0; $i -lt $script:ASYNC_PS.Streams.Information.Count; $i++) {
                Write-Host $script:ASYNC_PS.Streams.Information[$i].MessageData
            }
            if ($script:ASYNC_PS.Streams.Information.Count -gt 0) { $script:ASYNC_PS.Streams.Information.Clear() }

            for ($i = 0; $i -lt $script:ASYNC_PS.Streams.Warning.Count; $i++) {
                Write-Host "WARNING: $($script:ASYNC_PS.Streams.Warning[$i].Message)" -ForegroundColor Yellow
            }
            if ($script:ASYNC_PS.Streams.Warning.Count -gt 0) { $script:ASYNC_PS.Streams.Warning.Clear() }

            for ($i = 0; $i -lt $script:ASYNC_PS.Streams.Error.Count; $i++) {
                Write-Host "ERROR: $($script:ASYNC_PS.Streams.Error[$i].Exception.Message)" -ForegroundColor Red
            }
            if ($script:ASYNC_PS.Streams.Error.Count -gt 0) { $script:ASYNC_PS.Streams.Error.Clear() }

            if ($script:ASYNC_HANDLE.IsCompleted) {
                $script:ASYNC_TIMER.Stop()

                if ($script:ASYNC_PS.InvocationStateInfo.State -eq 'Stopped') {
                    Write-LogInfo 'Operation cancelled'
                    Invoke-WriteProgress -Id 1 -Activity 'Cancelled' -Completed
                }

                try { $script:ASYNC_PS.EndInvoke($script:ASYNC_HANDLE) } catch {}

                $script:ASYNC_PS.Dispose()
                $script:ASYNC_RUNSPACE.Dispose()

                $script:ASYNC_BUTTON.Content = $script:ASYNC_ORIGINAL_CONTENT
                $script:ASYNC_BUTTON.Resources.Remove('AccentColor')
                $script:ASYNC_BUTTON.Resources.Remove('AccentHoverColor')
                $script:ASYNC_BUTTON.Resources.Remove('AccentPressedColor')

                Set-Icon ([IconName]::Default)

                $script:ASYNC_OPERATION_RUNNING = $False
                $script:ASYNC_BUTTON = $Null
                $script:ASYNC_ORIGINAL_CONTENT = $Null
                $script:ASYNC_PS = $Null
                $script:ASYNC_HANDLE = $Null
                $script:ASYNC_RUNSPACE = $Null
                $script:ASYNC_TIMER = $Null
            }
        }
    )
    $script:ASYNC_TIMER.Start()
}


function Stop-AsyncOperation {
    if ($script:ASYNC_OPERATION_RUNNING -and $script:ASYNC_PS) {
        Write-LogWarning 'Cancelling operation...'
        $script:ASYNC_PS.Stop()
    }
}
