Set-Variable -Scope Script -Name ACTIVITIES -Value ([Collections.Stack]@())
Set-Variable -Scope Script -Name CURRENT_TASK -Value $Null

function Invoke-WriteProgress {
    param(
        [Parameter(Position = 0, Mandatory)][Int]$Id,
        [Parameter(Position = 1, Mandatory)][String]$Activity,
        [Parameter(Position = 2)][Int]$ParentId,
        [Parameter(Position = 3)][Int]$PercentComplete,
        [Parameter(Position = 4)][String]$Status,
        [Switch]$Completed
    )

    Set-Variable -Name Params -Value ([Hashtable]@{
            Id       = $Id
            Activity = $Activity
        })

    if ($ParentId -gt 0) { $Params.ParentId = $ParentId }
    if ($Status) { $Params.Status = $Status }

    if ($Completed) {
        $Params.Completed = $True
    } else {
        $Params.PercentComplete = $PercentComplete
    }

    Write-Progress @Params
}

function New-Activity {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Activity
    )

    Write-LogInfo "$Activity..."

    $ACTIVITIES.Push($Activity)

    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)

    if ($TaskLevel -gt 1) {
        Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
    } else {
        Set-Variable -Option Constant ParentId ([Int]0)
    }

    Invoke-WriteProgress -Id $TaskLevel -Activity $Activity -ParentId $ParentId -PercentComplete 1
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
}
