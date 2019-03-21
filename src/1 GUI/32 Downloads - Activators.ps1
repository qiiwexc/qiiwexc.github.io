$GRP_DownloadsActivators = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadsActivators.Text = 'Activators'
$GRP_DownloadsActivators.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 2
$GRP_DownloadsActivators.Width = $GRP_DownloadsTools.Width
$GRP_DownloadsActivators.Location = $GRP_DownloadsTools.Location + "$($GRP_DownloadsTools.Width + $INT_NORMAL), 0"


$BTN_DownloadKMS = New-Object System.Windows.Forms.Button
$BTN_DownloadKMS.Text = 'KMSAuto Lite'
$BTN_DownloadKMS.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadKMS.Height = $BTN_HEIGHT
$BTN_DownloadKMS.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadKMS.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMS, "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadKMS.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip' -Execute $CBOX_KMSExecute.Checked
    } )

$CBOX_KMSExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_KMSExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_KMSExecute.Location = $BTN_DownloadKMS.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_KMSExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_KMSExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadChew = New-Object System.Windows.Forms.Button
$BTN_DownloadChew.Text = 'ChewWGA'
$BTN_DownloadChew.Location = $BTN_DownloadKMS.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadChew.Height = $BTN_HEIGHT
$BTN_DownloadChew.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadChew.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChew, "Download ChewWGA`rFor activating hopeless Windows 7 installations`n`n$TXT_AV_WARNING")
$BTN_DownloadChew.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip' -Execute $CBOX_ChewExecute.Checked
    } )

$CBOX_ChewExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_ChewExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ChewExecute.Location = $BTN_DownloadChew.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ChewExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ChewExecute.Size = $CBOX_SIZE_DOWNLOAD


$TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GRP_DownloadsActivators))
$GRP_DownloadsActivators.Controls.AddRange(@($BTN_DownloadKMS, $BTN_DownloadChew, $CBOX_KMSExecute, $CBOX_ChewExecute))
