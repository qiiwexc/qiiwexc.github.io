Set-Variable -Scope Script -Name ACTIVITIES -Value ([Collections.Stack]@())
Set-Variable -Scope Script -Name CURRENT_TASK -Value $Null

function Invoke-WriteProgress {
    param(
        [Int][Parameter(Position = 0, Mandatory)]$Id,
        [String][Parameter(Position = 1, Mandatory)]$Activity,
        [Int][Parameter(Position = 2)]$ParentId,
        [Int][Parameter(Position = 3)]$PercentComplete,
        [String][Parameter(Position = 4)]$Status,
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
        [String][Parameter(Position = 0, Mandatory)]$Activity
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
        [Int][Parameter(Position = 0, Mandatory)]$PercentComplete,
        [String][Parameter(Position = 1)]$Task
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
        [Bool][Parameter(Position = 0)]$Success = $True
    )

    if ($Success) {
        Out-Success
    } else {
        Out-Failure "$CURRENT_TASK failed"
    }

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

    Set-Variable -Scope Script CURRENT_TASK $Null
}
