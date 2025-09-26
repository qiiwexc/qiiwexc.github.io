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

    Add-LogMessage "`n[$((Get-Date).ToString())] $Message"
}


function Add-LogMessage {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Write-Host -NoNewline $Text
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


function Out-Status {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Status
    )

    Add-LogMessage ' '

    Set-Variable -Option Constant LogDefaultFont $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)

    Add-LogMessage $Status

    $LOG.SelectionFont = $LogDefaultFont
    $LOG.SelectionColor = 'black'
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
