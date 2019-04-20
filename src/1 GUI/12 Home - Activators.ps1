$GRP_Activators = New-Object System.Windows.Forms.GroupBox
$GRP_Activators.Text = 'Activators'
$GRP_Activators.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Activators.Width = $GRP_WIDTH
$GRP_Activators.Location = $GRP_ThisUtility.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_HOME.Controls.Add($GRP_Activators)


$BTN_DownloadKMSAuto = New-Object System.Windows.Forms.Button
$BTN_DownloadKMSAuto.Text = 'KMSAuto Lite'
$BTN_DownloadKMSAuto.Height = $BTN_HEIGHT
$BTN_DownloadKMSAuto.Width = $BTN_WIDTH
$BTN_DownloadKMSAuto.Location = $BTN_INIT_LOCATION
$BTN_DownloadKMSAuto.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadKMSAuto, "Download KMSAuto Lite`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadKMSAuto.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $DownloadedFile = Start-Download 'qiiwexc.github.io/d/KMSAuto_Lite.zip'
        if ($CBOX_StartKMSAuto.Checked -and $DownloadedFile) { Start-File $DownloadedFile }
    } )

$CBOX_StartKMSAuto = New-Object System.Windows.Forms.CheckBox
$CBOX_StartKMSAuto.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartKMSAuto.Size = $CBOX_SIZE
$CBOX_StartKMSAuto.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartKMSAuto, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartKMSAuto.Add_CheckStateChanged( { $BTN_DownloadKMSAuto.Text = "KMSAuto Lite$(if ($CBOX_StartKMSAuto.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadAAct = New-Object System.Windows.Forms.Button
$BTN_DownloadAAct.Text = 'AAct (Win 7+, Office)'
$BTN_DownloadAAct.Height = $BTN_HEIGHT
$BTN_DownloadAAct.Width = $BTN_WIDTH
$BTN_DownloadAAct.Location = $BTN_DownloadKMSAuto.Location + $SHIFT_BTN_LONG
$BTN_DownloadAAct.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadAAct, "Download AAct`nActivates Windows 7 - 10 and Office 2010 - 2019`n`n$TXT_AV_WARNING")
$BTN_DownloadAAct.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $DownloadedFile = Start-Download 'qiiwexc.github.io/d/AAct.zip'
        if ($CBOX_StartAAct.Checked -and $DownloadedFile) { Start-File $DownloadedFile }
    } )

$CBOX_StartAAct = New-Object System.Windows.Forms.CheckBox
$CBOX_StartAAct.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartAAct.Size = $CBOX_SIZE
$CBOX_StartAAct.Location = $BTN_DownloadAAct.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartAAct, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartAAct.Add_CheckStateChanged( { $BTN_DownloadAAct.Text = "AAct (Win 7+, Office)$(if ($CBOX_StartAAct.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadChewWGA = New-Object System.Windows.Forms.Button
$BTN_DownloadChewWGA.Text = 'ChewWGA (Win 7)'
$BTN_DownloadChewWGA.Height = $BTN_HEIGHT
$BTN_DownloadChewWGA.Width = $BTN_WIDTH
$BTN_DownloadChewWGA.Location = $BTN_DownloadAAct.Location + $SHIFT_BTN_LONG
$BTN_DownloadChewWGA.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadChewWGA, "Download ChewWGA`nLast resort for activating hopeless Windows 7 cases`n`n$TXT_AV_WARNING")
$BTN_DownloadChewWGA.Add_Click( {
        Add-Log $WRN $TXT_AV_WARNING
        $DownloadedFile = Start-Download 'qiiwexc.github.io/d/ChewWGA.zip'
        if ($CBOX_StartChewWGA.Checked -and $DownloadedFile) { Start-File $DownloadedFile }
    } )

$CBOX_StartChewWGA = New-Object System.Windows.Forms.CheckBox
$CBOX_StartChewWGA.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartChewWGA.Size = $CBOX_SIZE
$CBOX_StartChewWGA.Location = $BTN_DownloadChewWGA.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartChewWGA, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartChewWGA.Add_CheckStateChanged( { $BTN_DownloadChewWGA.Text = "ChewWGA (Win 7)$(if ($CBOX_StartChewWGA.Checked) {$REQUIRES_ELEVATION})" } )


$GRP_Activators.Controls.AddRange(@($BTN_DownloadKMSAuto, $CBOX_StartKMSAuto, $BTN_DownloadAAct, $CBOX_StartAAct, $BTN_DownloadChewWGA, $CBOX_StartChewWGA))
