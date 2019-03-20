function Write-Log($Level, $Message) {
    $Text = "[$((Get-Date).ToString())] $Message"
    $_LOG.SelectionStart = $_LOG.TextLength

    switch ($Level) { $_WRN {$_LOG.SelectionColor = 'blue'} $_ERR {$_LOG.SelectionColor = 'red'} Default {$_LOG.SelectionColor = 'black'} }

    Write-Host $Text
    $_LOG.AppendText("`n$Text")

    $_LOG.SelectionColor = 'black'
    $_LOG.ScrollToCaret();
}


function ExecuteAsAdmin ($Command, $Message) {Start-Process -Wait -Verb RunAs -FilePath 'powershell' -ArgumentList "-Command `"Write-Host $Message; $Command`""}


function ExitScript {$_FORM.Close()}


function OpenInBrowser ($URL) {
    if ($URL.length -lt 1) {
        Write-Log $_ERR 'No URL specified'
        return
    }

    $UrlToOpen = if ($URL -like 'http*') {$URL} else {'https://' + $URL}
    Write-Log $_INF "Openning URL in the default browser: $UrlToOpen"

    try {[System.Diagnostics.Process]::Start($UrlToOpen)}
    catch [Exception] {Write-Log $_ERR "Could not open the URL: $($_.Exception.Message)"}
}
