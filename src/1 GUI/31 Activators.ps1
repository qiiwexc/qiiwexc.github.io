$GroupDownloadsActivators = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsActivators.Text = 'Activators'
$GroupDownloadsActivators.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 2 + $_INTERVAL_SHORT
$GroupDownloadsActivators.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_DOWNLOAD + $_INTERVAL_NORMAL
$GroupDownloadsActivators.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"


$ButtonDownloadKMS = New-Object System.Windows.Forms.Button
$ButtonDownloadKMS.Text = 'KMSAuto Lite'
$ButtonDownloadKMSToolTipText = "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadKMS.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadKMS.Height = $_BUTTON_HEIGHT
$ButtonDownloadKMS.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadKMS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadKMS, $ButtonDownloadKMSToolTipText)
$ButtonDownloadKMS.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip'
    } )

$ButtonDownloadChew = New-Object System.Windows.Forms.Button
$ButtonDownloadChew.Text = 'ChewWGA'
$ButtonDownloadChewToolTipText = "Download ChewWGA`rFor activating hopeless Windows 7 installations`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadChew.Location = $ButtonDownloadKMS.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonDownloadChew.Height = $_BUTTON_HEIGHT
$ButtonDownloadChew.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadChew.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChew, $ButtonDownloadChewToolTipText)
$ButtonDownloadChew.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip'
    } )


$_TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GroupDownloadsActivators))
$GroupDownloadsActivators.Controls.AddRange(@($ButtonDownloadKMS, $ButtonDownloadChew))
