function Add-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) { $WRN {$LOG.SelectionColor = 'blue'} $ERR {$LOG.SelectionColor = 'red'} Default {$LOG.SelectionColor = 'black'} }
    Write-Log "`n$Text"
}


function Write-Log($Text) {
    Write-Host $Text -NoNewline
    $LOG.AppendText($Text)
    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


function Set-Success {
    Write-Log(' ')
    $LogDefaultFont = $LOG.Font
    $LOG.SelectionFont = New-Object Drawing.Font($LogDefaultFont.FontFamily, $LogDefaultFont.Size, [Drawing.FontStyle]::Underline)
    Write-Log('Done')
    $LOG.SelectionFont = $LogDefaultFont
}


function Get-Connection {return $(if (-not (Get-NetAdapter -Physical | Where-Object Status -eq 'Up')) {'Computer is not connected to the Internet'})}


function Exit-Script {$FORM.Close()}


function Open-InBrowser ($Url) {
    if ($Url.length -lt 1) {
        Add-Log $ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    Add-Log $INF "Openning URL in the default browser: $UrlToOpen"

    try {[System.Diagnostics.Process]::Start($UrlToOpen)}
    catch [Exception] {Add-Log $ERR "Could not open the URL: $($_.Exception.Message)"}
}
