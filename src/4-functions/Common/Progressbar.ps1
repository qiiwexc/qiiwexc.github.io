function New-Activity {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Activity
    )

    Write-LogInfo $Activity
    Set-Variable -Scope Script CURRENT_ACTIVITY $Activity
    Write-Progress -Activity $CURRENT_ACTIVITY -PercentComplete 1
}

function Write-ActivityProgress {
    param(
        [Int][Parameter(Position = 0, Mandatory = $True)]$PercentComplete,
        [String][Parameter(Position = 1)]$Task
    )

    if ($Task) {
        Set-Variable -Scope Script CURRENT_TASK $Task
        Write-LogInfo $CURRENT_TASK
    }

    if ($CURRENT_ACTIVITY) {
        Write-Progress -Activity $CURRENT_ACTIVITY -Status $CURRENT_TASK -PercentComplete $PercentComplete
    }
}

function Write-ActivityCompleted {
    Out-Success
    Write-Progress -Activity $CURRENT_ACTIVITY -Completed
    Set-Variable -Scope Script CURRENT_ACTIVITY $Null
    Set-Variable -Scope Script CURRENT_TASK $Null
}
