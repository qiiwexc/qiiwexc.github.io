function Write-Log {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) {
        $WRN {
            $LOG.SelectionColor = 'blue'
        }
        $ERR {
            $LOG.SelectionColor = 'red'
        }
        Default {
            $LOG.SelectionColor = 'black'
        }
    }

    Add-LogMessage $Level "[$((Get-Date).ToString())] $Message"
}


function Add-LogMessage {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Text
    )

    switch ($Level) {
        $INF {
            Write-Host $Text
        }
        $WRN {
            Write-Warning $Text
        }
        $ERR {
            Write-Error $Text
        }
        Default {
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

    Write-Log $INF "   > $Status"
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

    Write-Log $ERR "$($Message): $($Exception.Exception.Message)"
}
