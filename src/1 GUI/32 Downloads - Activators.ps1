$GRP_Activators = New-Object System.Windows.Forms.GroupBox
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 2
$GRP_Activators.Width = $GRP_DownloadTools.Width
$GRP_Activators.Location = $GRP_DownloadTools.Location + "$($GRP_DownloadTools.Width + $INT_NORMAL), 0"
$TAB_TOOLS_AND_ISO.Controls.Add($GRP_Activators)


$BTN_DownloadKMSAuto = New-Object System.Windows.Forms.Button
$BTN_DownloadKMSAuto.Text = 'KMSAuto Lite'
$BTN_DownloadKMSAuto.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadKMSAuto.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadKMSAuto.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`rActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadKMSAuto.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/KMSAuto_Lite.zip' -Execute $CBOX_ExecuteKMSAuto.Checked
    } )

$CBOX_ExecuteKMSAuto = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteKMSAuto.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteKMSAuto, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteKMSAuto.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadChewWGA = New-Object System.Windows.Forms.Button
$BTN_DownloadChewWGA.Text = 'ChewWGA'
$BTN_DownloadChewWGA.Height = $BTN_HEIGHT
$BTN_DownloadChewWGA.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadChewWGA.Location = $BTN_DownloadKMSAuto.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadChewWGA.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChewWGA, "Download ChewWGA`rFor activating hopeless Windows 7 installations`n`n$TXT_AV_WARNING")
$BTN_DownloadChewWGA.Add_Click( {
        Write-Log $WRN $TXT_AV_WARNING
        DownloadFile 'qiiwexc.github.io/d/ChewWGA.zip' -Execute $CBOX_ExecuteChewWGA.Checked
    } )

$CBOX_ExecuteChewWGA = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteChewWGA.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteChewWGA.Location = $BTN_DownloadChewWGA.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteChewWGA, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteChewWGA.Size = $CBOX_SIZE_DOWNLOAD


$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $BTN_DownloadChewWGA, $CBOX_ExecuteKMSAuto, $CBOX_ExecuteChewWGA))
