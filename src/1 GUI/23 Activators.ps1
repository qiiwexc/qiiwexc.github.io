$GroupDownloadsActivators = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsActivators.Text = 'Activators'
$GroupDownloadsActivators.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 2 + $_INTERVAL_SHORT
$GroupDownloadsActivators.Width = $GroupDownloadsInstallersSoftware.Width
$GroupDownloadsActivators.Location = $GroupDownloadsInstallersSoftware.Location + "0, $($GroupDownloadsInstallersSoftware.Height + $_INTERVAL_NORMAL + 2)"
$_TAB_DOWNLOADS.Controls.Add($GroupDownloadsActivators)


$ButtonDownloadKMS = New-Object System.Windows.Forms.Button
$ButtonDownloadKMS.Text = 'KMSAuto Lite'
$ButtonDownloadKMSToolTipText = "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019"
$ButtonDownloadKMS.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadKMS.Height = $_BUTTON_HEIGHT
$ButtonDownloadKMS.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadKMS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadKMS, $ButtonDownloadKMSToolTipText)
$ButtonDownloadKMS.Add_Click( {DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip'} )
$GroupDownloadsActivators.Controls.Add($ButtonDownloadKMS)

$ButtonDownloadChew = New-Object System.Windows.Forms.Button
$ButtonDownloadChew.Text = 'ChewWGA'
$ButtonDownloadChewToolTipText = "Download ChewWGA`rFor activating hopeless Windows 7 installations"
$ButtonDownloadChew.Location = $ButtonDownloadKMS.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadChew.Height = $_BUTTON_HEIGHT
$ButtonDownloadChew.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadChew.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChew, $ButtonDownloadChewToolTipText)
$ButtonDownloadChew.Add_Click( {DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip'} )
$GroupDownloadsActivators.Controls.Add($ButtonDownloadChew)
