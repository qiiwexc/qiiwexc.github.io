$GRP_InstallTools = New-Object System.Windows.Forms.GroupBox
$GRP_InstallTools.Text = 'Tools'
$GRP_InstallTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 4 + $INT_NORMAL
$GRP_InstallTools.Width = $GRP_Essentials.Width
$GRP_InstallTools.Location = $GRP_Essentials.Location + "$($GRP_Essentials.Width + $INT_NORMAL), 0"
$TAB_INSTALLERS.Controls.Add($GRP_InstallTools)


$BTN_DownloadCCleaner = New-Object System.Windows.Forms.Button
$BTN_DownloadCCleaner.Text = 'CCleaner'
$BTN_DownloadCCleaner.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadCCleaner.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
$BTN_DownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe' -Execute $CBOX_ExecuteCCleaner.Checked} )

$CBOX_ExecuteCCleaner = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteCCleaner.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteCCleaner.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteCCleaner, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteCCleaner.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadDefraggler = New-Object System.Windows.Forms.Button
$BTN_DownloadDefraggler.Text = 'Defraggler'
$BTN_DownloadDefraggler.Height = $BTN_HEIGHT
$BTN_DownloadDefraggler.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadDefraggler.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDefraggler, 'Download Defraggler installer')
$BTN_DownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe' -Execute $CBOX_ExecuteDefraggler.Checked} )

$CBOX_ExecuteDefraggler = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteDefraggler.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteDefraggler.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteDefraggler, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteDefraggler.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadRecuva = New-Object System.Windows.Forms.Button
$BTN_DownloadRecuva.Text = 'Recuva'
$BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_DownloadRecuva.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRecuva.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRecuva.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`rRecuva helps restore deleted files")
$BTN_DownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe' -Execute $CBOX_ExecuteRecuva.Checked} )

$CBOX_ExecuteRecuva = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteRecuva.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteRecuva.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteRecuva, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteRecuva.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadMalwarebytes = New-Object System.Windows.Forms.Button
$BTN_DownloadMalwarebytes.Text = 'Malwarebytes'
$BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_DownloadMalwarebytes.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadMalwarebytes.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_NORMAL
$BTN_DownloadMalwarebytes.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware")
$BTN_DownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' -Execute $CBOX_ExecuteMalwarebytes.Checked} )

$CBOX_ExecuteMalwarebytes = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteMalwarebytes.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteMalwarebytes.Location = $BTN_DownloadMalwarebytes.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteMalwarebytes, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteMalwarebytes.Size = $CBOX_SIZE_DOWNLOAD


$GRP_InstallTools.Controls.AddRange(@(
        $BTN_DownloadCCleaner, $BTN_DownloadDefraggler, $BTN_DownloadRecuva, $BTN_DownloadMalwarebytes,
        $CBOX_ExecuteCCleaner, $CBOX_ExecuteDefraggler, $CBOX_ExecuteRecuva, $CBOX_ExecuteMalwarebytes
    ))
