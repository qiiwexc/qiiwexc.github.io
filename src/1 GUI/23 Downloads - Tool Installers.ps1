$GRP_InstallersTools = New-Object System.Windows.Forms.GroupBox
$GRP_InstallersTools.Text = 'Tools'
$GRP_InstallersTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 4 + $INT_NORMAL
$GRP_InstallersTools.Width = $GRP_Essentials.Width
$GRP_InstallersTools.Location = $GRP_Essentials.Location + "$($GRP_Essentials.Width + $INT_NORMAL), 0"


$BTN_DownloadCCleaner = New-Object System.Windows.Forms.Button
$BTN_DownloadCCleaner.Text = 'CCleaner'
$BTN_DownloadCCleaner.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadCCleaner.Height = $BTN_HEIGHT
$BTN_DownloadCCleaner.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadCCleaner.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadCCleaner, 'Download CCleaner installer')
$BTN_DownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe' -Execute $CBOX_CCleanerExecute.Checked} )

$CBOX_CCleanerExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_CCleanerExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_CCleanerExecute.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_CCleanerExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_CCleanerExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadDefraggler = New-Object System.Windows.Forms.Button
$BTN_DownloadDefraggler.Text = 'Defraggler'
$BTN_DownloadDefraggler.Location = $BTN_DownloadCCleaner.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadDefraggler.Height = $BTN_HEIGHT
$BTN_DownloadDefraggler.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadDefraggler.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadDefraggler, 'Download Defraggler installer')
$BTN_DownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe' -Execute $CBOX_DefragglerExecute.Checked} )

$CBOX_DefragglerExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_DefragglerExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_DefragglerExecute.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_DefragglerExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_DefragglerExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadRecuva = New-Object System.Windows.Forms.Button
$BTN_DownloadRecuva.Text = 'Recuva'
$BTN_DownloadRecuva.Location = $BTN_DownloadDefraggler.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_DownloadRecuva.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRecuva.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`rRecuva helps restore deleted files")
$BTN_DownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe' -Execute $CBOX_RecuvaExecute.Checked} )

$CBOX_RecuvaExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_RecuvaExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_RecuvaExecute.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_RecuvaExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_RecuvaExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadMalwarebytes = New-Object System.Windows.Forms.Button
$BTN_DownloadMalwarebytes.Text = 'Malwarebytes'
$BTN_DownloadMalwarebytes.Location = $BTN_DownloadRecuva.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_NORMAL
$BTN_DownloadMalwarebytes.Height = $BTN_HEIGHT
$BTN_DownloadMalwarebytes.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadMalwarebytes.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadMalwarebytes, "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware")
$BTN_DownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' $CBOX_MalwarebytesExecute.Checked} )

$CBOX_MalwarebytesExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_MalwarebytesExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_MalwarebytesExecute.Location = $BTN_DownloadMalwarebytes.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_MalwarebytesExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_MalwarebytesExecute.Size = $CBOX_SIZE_DOWNLOAD


$TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GRP_InstallersTools))
$GRP_InstallersTools.Controls.AddRange(@(
        $BTN_DownloadCCleaner, $BTN_DownloadDefraggler, $BTN_DownloadRecuva, $BTN_DownloadMalwarebytes,
        $CBOX_CCleanerExecute, $CBOX_DefragglerExecute, $CBOX_RecuvaExecute, $CBOX_MalwarebytesExecute
    ))
