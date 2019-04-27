function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1)]$Message = $(Write-Host "`n>>> $($MyInvocation.MyCommand.Name): Log message missing <<<" -NoNewline)
    )
    if (-not $Message) { Return }

    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) { $WRN { $LOG.SelectionColor = 'blue' } $ERR { $LOG.SelectionColor = 'red' } Default { $LOG.SelectionColor = 'black' } }
    Write-Log "`n$Text"
}


function Write-Log {
    Param([String]$Text = $(Write-Host "`n>>> $($MyInvocation.MyCommand.Name): Log message missing <<<" -NoNewline))
    if (-not $Text) { Return }

    Write-Host $Text -NoNewline
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


function Out-Success {
    Write-Log(' ')
    $LogDefaultFont = $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)
    Write-Log('Done')
    $LOG.SelectionFont = $LogDefaultFont
}
