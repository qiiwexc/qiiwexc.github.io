function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1)]$Message = $(Write-Host "`n$($MyInvocation.MyCommand.Name): Log message missing" -NoNewline)
    )
    if (-not $Message) { Return }

    Set-Variable Text "[$((Get-Date).ToString())] $Message" -Option Constant
    $LOG.SelectionStart = $LOG.TextLength

    Switch ($Level) { $WRN { $LOG.SelectionColor = 'blue' } $ERR { $LOG.SelectionColor = 'red' } Default { $LOG.SelectionColor = 'black' } }
    Write-Log "`n$Text"
}


function Write-Log {
    Param([String]$Text = $(Write-Host "`n$($MyInvocation.MyCommand.Name): Log message missing" -NoNewline))
    if (-not $Text) { Return }

    Write-Host $Text -NoNewline
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


function Out-Status {
    Param([String][ValidateSet('Done', 'Failed')]$Status = $(Write-Host "`n$($MyInvocation.MyCommand.Name): No status specified" -NoNewline))
    if (-not $Status) { Return }

    Set-Variable LogDefaultFont $LOG.Font -Option Constant
    Write-Log(' ')

    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)

    Write-Log($Status)

    $LOG.SelectionFont = $LogDefaultFont
    $LOG.SelectionColor = 'black'
}


function Out-Success { Out-Status 'Done' }

function Out-Failure { Out-Status 'Failed' }
