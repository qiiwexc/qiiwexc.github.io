Function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1)]$Message = $(Write-Host -NoNewline "`n$($MyInvocation.MyCommand.Name): Log message missing")
    )
    if (-not $Message) { Return }

    $LOG.SelectionStart = $LOG.TextLength

    Switch ($Level) { $WRN { $LOG.SelectionColor = 'blue' } $ERR { $LOG.SelectionColor = 'red' } Default { $LOG.SelectionColor = 'black' } }
    Write-Log "`n[$((Get-Date).ToString())] $Message"
}


Function Write-Log {
    Param([String]$Text = $(Write-Host -NoNewline "`n$($MyInvocation.MyCommand.Name): Log message missing"))
    if (-not $Text) { Return }

    Write-Host -NoNewline $Text
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret()
}


Function Out-Status {
    Param([String]$Status = $(Write-Host -NoNewline "`n$($MyInvocation.MyCommand.Name): No status specified"))
    if (-not $Status) { Return }

    Write-Log ' '

    Set-Variable -Option Constant LogDefaultFont $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)

    Write-Log $Status

    $LOG.SelectionFont = $LogDefaultFont
    $LOG.SelectionColor = 'black'
}


Function Out-Success { Out-Status 'Done' }

Function Out-Failure { Out-Status 'Failed' }
