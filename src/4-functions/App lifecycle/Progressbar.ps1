function New-Activity {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Activity
    )

    Write-LogInfo "$Activity..."

    $ACTIVITIES.Push($Activity)

    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)

    if ($TaskLevel -gt 1) {
        Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
    }

    if ($ParentId) {
        Write-Progress -Id $TaskLevel -Activity $Activity -PercentComplete 1 -ParentId $ParentId
    } else {
        Write-Progress -Id $TaskLevel -Activity $Activity -PercentComplete 1
    }
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
        }

        if ($Task) {
            Set-Variable -Scope Script CURRENT_TASK ([String]$Task)
            Write-LogInfo $Task

            if ($ParentId) {
                Write-Progress -Id $TaskLevel -Activity $Activity -Status $Task -PercentComplete $PercentComplete -ParentId $ParentId
            } else {
                Write-Progress -Id $TaskLevel -Activity $Activity -Status $Task -PercentComplete $PercentComplete
            }
        } else {
            if ($ParentId) {
                Write-Progress -Id $TaskLevel -Activity $Activity -PercentComplete $PercentComplete -ParentId $ParentId
            } else {
                Write-Progress -Id $TaskLevel -Activity $Activity -PercentComplete $PercentComplete
            }
        }
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
        }

        if ($ParentId) {
            Write-Progress -Id $TaskLevel -Activity $Activity -Completed -ParentId $ParentId
        } else {
            Write-Progress -Id $TaskLevel -Activity $Activity -Completed
        }
    }

    Set-Variable -Scope Script CURRENT_TASK $Null
}
