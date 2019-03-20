$GroupDownloadsActivators = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsActivators.Text = 'Activators'
$GroupDownloadsActivators.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 2
$GroupDownloadsActivators.Width = $GroupDownloadsTools.Width
$GroupDownloadsActivators.Location = $GroupDownloadsTools.Location + "$($GroupDownloadsTools.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadKMS = New-Object System.Windows.Forms.Button
$ButtonDownloadKMS.Text = 'KMSAuto Lite'
$ButtonDownloadKMSToolTipText = "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadKMS.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadKMS.Height = $_BUTTON_HEIGHT
$ButtonDownloadKMS.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadKMS.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadKMS, $ButtonDownloadKMSToolTipText)
$ButtonDownloadKMS.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip' -Execute $CheckBoxKMSExecute.Checked
    } )

$CheckBoxKMSExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxKMSExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxKMSExecute.Location = $ButtonDownloadKMS.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxKMSExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxKMSExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadChew = New-Object System.Windows.Forms.Button
$ButtonDownloadChew.Text = 'ChewWGA'
$ButtonDownloadChewToolTipText = "Download ChewWGA`rFor activating hopeless Windows 7 installations`n`n$_AV_WARNING_MESSAGE"
$ButtonDownloadChew.Location = $ButtonDownloadKMS.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadChew.Height = $_BUTTON_HEIGHT
$ButtonDownloadChew.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadChew.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadChew, $ButtonDownloadChewToolTipText)
$ButtonDownloadChew.Add_Click( {
        Write-Log $_WRN $_AV_WARNING_MESSAGE
        DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip' -Execute $CheckBoxChewExecute.Checked
    } )

$CheckBoxChewExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxChewExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxChewExecute.Location = $ButtonDownloadChew.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxChewExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxChewExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$_TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GroupDownloadsActivators))
$GroupDownloadsActivators.Controls.AddRange(@($ButtonDownloadKMS, $ButtonDownloadChew, $CheckBoxKMSExecute, $CheckBoxChewExecute))
