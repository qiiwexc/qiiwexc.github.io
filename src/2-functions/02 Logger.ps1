Function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    $LOG.SelectionStart = $LOG.TextLength

    Switch ($Level) {
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

    Write-Log "`n[$((Get-Date).ToString())] $Message"
}


Function Write-Log {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Text)

    Write-Host -NoNewline $Text
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


Function Out-Status {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$Status)

    Write-Log ' '

    Set-Variable -Option Constant LogDefaultFont $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)

    Write-Log $Status

    $LOG.SelectionFont = $LogDefaultFont
    $LOG.SelectionColor = 'black'
}


Function Out-Success { Out-Status 'Done' }

Function Out-Failure { Out-Status 'Failed' }
