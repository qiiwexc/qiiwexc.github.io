Set-Variable -Scope Script -Name ACTIVITIES -Value ([Collections.Stack]@())
Set-Variable -Scope Script -Name CURRENT_TASK -Value $Null
Set-Variable -Scope Script -Name PROGRESSBAR_RESET_TIMER -Value $Null

function Invoke-WriteProgress {
    param(
        [Parameter(Position = 0, Mandatory)][Int]$Id,
        [Parameter(Position = 1, Mandatory)][String]$Activity,
        [Parameter(Position = 2)][Int]$ParentId,
        [Parameter(Position = 3)][Int]$PercentComplete,
        [Parameter(Position = 4)][String]$Status,
        [Switch]$Completed
    )

    Set-Variable -Name Params -Value (
        [Hashtable]@{
            Id       = $Id
            Activity = $Activity
        }
    )

    if ($ParentId -gt 0) {
        $Params.ParentId = $ParentId
    }

    if ($Status) {
        $Params.Status = $Status
    }

    if ($Completed) {
        $Params.Completed = $True

        if ($ParentId -eq 0) {
            Invoke-OnDispatcher 'Set-ProgressBarValue' @{ Value = 100 } -FlushRender
        }
    } else {
        $Params.PercentComplete = $PercentComplete

        if ($ParentId -eq 0) {
            Invoke-OnDispatcher 'Set-ProgressBarValue' @{ Value = $PercentComplete } -FlushRender
        }
    }

    Write-Progress @Params
}

# Touches the window, so it runs on the UI thread only, through Invoke-OnDispatcher
function Set-ProgressBarValue {
    param(
        [Parameter(Position = 0, Mandatory)][Int]$Value
    )

    $PROGRESSBAR.Value = $Value
}

# Empties the progress bar, and drops a reset still waiting to. Runs on the UI thread, which the timer belongs to
function Reset-ProgressBar {
    if ($script:PROGRESSBAR_RESET_TIMER) {
        $script:PROGRESSBAR_RESET_TIMER.Stop()
        Set-Variable -Scope Script PROGRESSBAR_RESET_TIMER $Null
    }

    Invoke-OnDispatcher 'Set-ProgressBarValue' @{ Value = 0 }
}

# Empties the progress bar once how an operation ended has been on it for a few seconds. Runs on the UI thread,
# whose dispatcher the timer ticks on
function Start-ProgressBarReset {
    if ($script:PROGRESSBAR_RESET_TIMER) {
        $script:PROGRESSBAR_RESET_TIMER.Stop()
    }

    Set-Variable -Scope Script PROGRESSBAR_RESET_TIMER ([Windows.Threading.DispatcherTimer]::new())
    $script:PROGRESSBAR_RESET_TIMER.Interval = [TimeSpan]::FromSeconds(3)
    $script:PROGRESSBAR_RESET_TIMER.Add_Tick( { Reset-ProgressBar } )
    $script:PROGRESSBAR_RESET_TIMER.Start()
}

function New-Activity {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Activity
    )

    Write-LogInfo "$Activity..."

    Set-Icon ([IconName]::Working)

    $ACTIVITIES.Push($Activity)

    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)

    if ($TaskLevel -gt 1) {
        Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
    } else {
        Set-Variable -Option Constant ParentId ([Int]0)
    }

    Invoke-WriteProgress -Id $TaskLevel -Activity $Activity -ParentId $ParentId -PercentComplete 5
}

function Write-ActivityProgress {
    param(
        [Parameter(Position = 0, Mandatory)][Int]$PercentComplete,
        [Parameter(Position = 1)][String]$Task
    )

    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)

    if ($TaskLevel -gt 0) {
        Set-Variable -Option Constant Activity ([String]$ACTIVITIES.Peek())

        if ($TaskLevel -gt 1) {
            Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
        } else {
            Set-Variable -Option Constant ParentId ([Int]0)
        }

        if ($Task) {
            Set-Variable -Scope Script CURRENT_TASK ([String]$Task)
            Write-LogInfo $Task
        }

        Invoke-WriteProgress -Id $TaskLevel -Activity $Activity -ParentId $ParentId -PercentComplete $PercentComplete -Status $Task
    }
}

function Write-ActivityCompleted {
    param(
        [Parameter(Position = 0)][Bool]$Success = $True
    )

    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)

    if ($TaskLevel -gt 0) {
        Set-Variable -Option Constant Activity ([String]$ACTIVITIES.Pop())

        if ($TaskLevel -gt 1) {
            Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
        } else {
            Set-Variable -Option Constant ParentId ([Int]0)
        }

        Invoke-WriteProgress -Id $TaskLevel -Activity $Activity -ParentId $ParentId -Completed
    }

    if ($Success) {
        Out-Success
    } else {
        Out-Failure "$CURRENT_TASK failed"
    }

    Set-Variable -Scope Script CURRENT_TASK $Null

    if ($TaskLevel -eq 1) {
        Set-Icon (([IconName]::Default))
    }
}
