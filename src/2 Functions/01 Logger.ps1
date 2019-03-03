$_INF = 'INF'
$_WRN = 'WRN'
$_ERR = 'ERR'

function Write-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    $_LOG.SelectionStart = $_LOG.TextLength

    switch ($Level) { $_WRN {$_LOG.SelectionColor = 'blue'} $_ERR {$_LOG.SelectionColor = 'red'} }

    Write-Host $Text
    $_LOG.AppendText("`n$Text")
    $_LOG.SelectionColor = 'black'
    $_LOG.ScrollToCaret();
}
