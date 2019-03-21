function Write-Log($Level, $Message) {
    $Text = "[$((Get-Date).ToString())] $Message"
    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) { $WRN {$LOG.SelectionColor = 'blue'} $ERR {$LOG.SelectionColor = 'red'} Default {$LOG.SelectionColor = 'black'} }

    Write-Host $Text
    $LOG.AppendText("`n$Text")

    $LOG.SelectionColor = 'black'
    $LOG.ScrollToCaret();
}


function ExecuteAsAdmin ($Command, $Message) {Start-Process -Wait -Verb RunAs -FilePath 'powershell' -ArgumentList "-Command `"Write-Host $Message; $Command`""}


function ExitScript {$FORM.Close()}


function OpenInBrowser ($Url) {
    if ($Url.length -lt 1) {
        Write-Log $ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($Url -like 'http*') {$Url} else {'https://' + $Url}
    Write-Log $INF "Openning URL in the default browser: $UrlToOpen"

    try {[System.Diagnostics.Process]::Start($UrlToOpen)}
    catch [Exception] {Write-Log $ERR "Could not open the URL: $($_.Exception.Message)"}
}
