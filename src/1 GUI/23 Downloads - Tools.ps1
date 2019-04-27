$GRP_InstallTools = New-Object System.Windows.Forms.GroupBox
$GRP_InstallTools.Text = 'Tools'
$GRP_InstallTools.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_InstallTools.Width = $GRP_WIDTH
$GRP_InstallTools.Location = $GRP_Essentials.Location + "0, $($GRP_Essentials.Height + $INT_NORMAL)"
$TAB_INSTALLERS.Controls.Add($GRP_InstallTools)


$BTN_DownloadCCleaner = New-Object System.Windows.Forms.Button
$BTN_DownloadCCleaner.Text = 'CCleaner'
$BTN_DownloadCCleaner.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_WIDTH
$BTN_DownloadCCleaner.Location = $BTN_INIT_LOCATION
$BTN_DownloadCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
$BTN_DownloadCCleaner.Add_Click( { Start-DownloadAndExecute 'download.ccleaner.com/ccsetup.exe' -Execute $CBOX_StartCCleaner.Checked } )

$CBOX_StartCCleaner = New-Object System.Windows.Forms.CheckBox
$CBOX_StartCCleaner.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartCCleaner.Size = $CBOX_SIZE
$CBOX_StartCCleaner.Location = $BTN_DownloadCCleaner.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartCCleaner, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartCCleaner.Add_CheckStateChanged( { $BTN_DownloadCCleaner.Text = "CCleaner$(if ($CBOX_StartCCleaner.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadDefraggler = New-Object System.Windows.Forms.Button
$BTN_DownloadDefraggler.Text = 'Defraggler'
$BTN_DownloadDefraggler.Height = $BTN_HEIGHT
$BTN_DownloadDefraggler.Width = $BTN_WIDTH
$BTN_DownloadDefraggler.Location = $BTN_DownloadCCleaner.Location + $SHIFT_BTN_LONG
$BTN_DownloadDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDefraggler, 'Download Defraggler installer')
$BTN_DownloadDefraggler.Add_Click( { Start-DownloadAndExecute 'download.ccleaner.com/dfsetup.exe' -Execute $CBOX_StartDefraggler.Checked } )

$CBOX_StartDefraggler = New-Object System.Windows.Forms.CheckBox
$CBOX_StartDefraggler.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartDefraggler.Size = $CBOX_SIZE
$CBOX_StartDefraggler.Location = $BTN_DownloadDefraggler.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartDefraggler, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartDefraggler.Add_CheckStateChanged( { $BTN_DownloadDefraggler.Text = "Defraggler$(if ($CBOX_StartDefraggler.Checked) {$REQUIRES_ELEVATION})" } )


$GRP_InstallTools.Controls.AddRange(@($BTN_DownloadCCleaner, $CBOX_StartCCleaner, $BTN_DownloadDefraggler, $CBOX_StartDefraggler))
