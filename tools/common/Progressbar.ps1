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

    Set-Variable -Option Constant Activity ([String]$ACTIVITIES.Peek())
    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)

    if ($TaskLevel -gt 1) {
        Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
    }

    if ($Activity) {
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
    Set-Variable -Option Constant TaskLevel ([Int]$ACTIVITIES.Count)

    if ($TaskLevel -gt 1) {
        Set-Variable -Option Constant ParentId ([Int]$TaskLevel - 1)
    }

    if ($ParentId) {
        Write-Progress -Id $TaskLevel -Activity $ACTIVITIES.Pop() -Completed -ParentId $ParentId
    } else {
        Write-Progress -Id $TaskLevel -Activity $ACTIVITIES.Pop() -Completed
    }

    Out-Success
    Set-Variable -Scope Script CURRENT_TASK $Null
}
