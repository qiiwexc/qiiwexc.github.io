function Write-LogInfo {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'INFO' $Message
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'WARN' $Message
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'ERROR' $Message
}

function Write-Log {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INFO', 'WARN', 'ERROR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"

    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) {
        'INFO' {
            $LOG.SelectionColor = 'black'
            Write-Host $Text
        }
        'WARN' {
            $LOG.SelectionColor = 'blue'
            Write-Warning $Text
        }
        'ERROR' {
            $LOG.SelectionColor = 'red'
            Write-Error $Text
        }
        Default {
            $LOG.SelectionColor = 'black'
            Write-Host $Text
        }
    }

    $LOG.AppendText("$Text`n")
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


function Out-Status {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Status
    )

    Write-LogInfo "   > $Status"
}


function Out-Success {
    Out-Status 'Done'
}

function Out-Failure {
    Out-Status 'Failed'
}


function Write-ExceptionLog {
    param(
        [PSCustomObject][Parameter(Position = 0, Mandatory = $True)]$Exception,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Write-LogError "$($Message): $($Exception.Exception.Message)"
}
