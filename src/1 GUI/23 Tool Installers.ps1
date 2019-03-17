$GroupInstallersTools = New-Object System.Windows.Forms.GroupBox
$GroupInstallersTools.Text = 'Tools'
$GroupInstallersTools.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 4 + $_INTERVAL_NORMAL
$GroupInstallersTools.Width = $GroupEssentials.Width
$GroupInstallersTools.Location = $GroupEssentials.Location + "$($GroupEssentials.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadCCleaner = New-Object System.Windows.Forms.Button
$ButtonDownloadCCleaner.Text = 'CCleaner'
$ButtonDownloadCCleanerToolTipText = 'Download CCleaner installer'
$ButtonDownloadCCleaner.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadCCleaner.Height = $_BUTTON_HEIGHT
$ButtonDownloadCCleaner.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadCCleaner.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadCCleaner, $ButtonDownloadCCleanerToolTipText)
$ButtonDownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe' -Execute $CheckBoxUncheckyExecute.Checked} )

$CheckBoxCCleanerExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxCCleanerExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxCCleanerExecute.Location = $ButtonDownloadCCleaner.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxCCleanerExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxCCleanerExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadDefraggler = New-Object System.Windows.Forms.Button
$ButtonDownloadDefraggler.Text = 'Defraggler'
$ButtonDownloadDefragglerToolTipText = 'Download Defraggler installer'
$ButtonDownloadDefraggler.Location = $ButtonDownloadCCleaner.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadDefraggler.Height = $_BUTTON_HEIGHT
$ButtonDownloadDefraggler.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadDefraggler.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadDefraggler, $ButtonDownloadDefragglerToolTipText)
$ButtonDownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe' -Execute $CheckBoxUncheckyExecute.Checked} )

$CheckBoxDefragglerExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxDefragglerExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxDefragglerExecute.Location = $ButtonDownloadDefraggler.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxDefragglerExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxDefragglerExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadRecuva = New-Object System.Windows.Forms.Button
$ButtonDownloadRecuva.Text = 'Recuva'
$ButtonDownloadRecuvaToolTipText = "Download Recuva installer`rRecuva helps restore deleted files"
$ButtonDownloadRecuva.Location = $ButtonDownloadDefraggler.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadRecuva.Height = $_BUTTON_HEIGHT
$ButtonDownloadRecuva.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadRecuva.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRecuva, $ButtonDownloadRecuvaToolTipText)
$ButtonDownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe' -Execute $CheckBoxUncheckyExecute.Checked} )

$CheckBoxRecuvaExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxRecuvaExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxRecuvaExecute.Location = $ButtonDownloadRecuva.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxRecuvaExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxRecuvaExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadMalwarebytes = New-Object System.Windows.Forms.Button
$ButtonDownloadMalwarebytes.Text = 'Malwarebytes'
$ButtonDownloadMalwarebytesToolTipText = "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware"
$ButtonDownloadMalwarebytes.Location = $ButtonDownloadRecuva.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_NORMAL
$ButtonDownloadMalwarebytes.Height = $_BUTTON_HEIGHT
$ButtonDownloadMalwarebytes.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadMalwarebytes.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadMalwarebytes, $ButtonDownloadMalwarebytesToolTipText)
$ButtonDownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'Ninite Malwarebytes Installer.exe' $CheckBoxUncheckyExecute.Checked} )

$CheckBoxMalwarebytesExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxMalwarebytesExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxMalwarebytesExecute.Location = $ButtonDownloadMalwarebytes.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxMalwarebytesExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxMalwarebytesExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$_TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GroupInstallersTools))
$GroupInstallersTools.Controls.AddRange(@(
        $ButtonDownloadCCleaner, $ButtonDownloadDefraggler, $ButtonDownloadRecuva, $ButtonDownloadMalwarebytes,
        $CheckBoxCCleanerExecute, $CheckBoxDefragglerExecute, $CheckBoxRecuvaExecute, $CheckBoxMalwarebytesExecute
    ))
