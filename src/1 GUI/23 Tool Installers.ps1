$GroupInstallersTools = New-Object System.Windows.Forms.GroupBox
$GroupInstallersTools.Text = 'Tools'
$GroupInstallersTools.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 2 + $_BUTTON_INTERVAL_SHORT * 2 + $_INTERVAL_SHORT
$GroupInstallersTools.Width = $GroupEssentials.Width
$GroupInstallersTools.Location = $GroupEssentials.Location + "$($GroupEssentials.Width + $_INTERVAL_NORMAL), 0"


$ButtonDownloadCCleaner = New-Object System.Windows.Forms.Button
$ButtonDownloadCCleaner.Text = 'CCleaner'
$ButtonDownloadCCleanerToolTipText = 'Download CCleaner installer'
$ButtonDownloadCCleaner.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadCCleaner.Height = $_BUTTON_HEIGHT
$ButtonDownloadCCleaner.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadCCleaner.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadCCleaner, $ButtonDownloadCCleanerToolTipText)
$ButtonDownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe'} )

$ButtonDownloadDefraggler = New-Object System.Windows.Forms.Button
$ButtonDownloadDefraggler.Text = 'Defraggler'
$ButtonDownloadDefragglerToolTipText = 'Download Defraggler installer'
$ButtonDownloadDefraggler.Location = $ButtonDownloadCCleaner.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonDownloadDefraggler.Height = $_BUTTON_HEIGHT
$ButtonDownloadDefraggler.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadDefraggler.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadDefraggler, $ButtonDownloadDefragglerToolTipText)
$ButtonDownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe'} )

$ButtonDownloadRecuva = New-Object System.Windows.Forms.Button
$ButtonDownloadRecuva.Text = 'Recuva'
$ButtonDownloadRecuvaToolTipText = "Download Recuva installer`rRecuva helps restore deleted files"
$ButtonDownloadRecuva.Location = $ButtonDownloadDefraggler.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonDownloadRecuva.Height = $_BUTTON_HEIGHT
$ButtonDownloadRecuva.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadRecuva.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRecuva, $ButtonDownloadRecuvaToolTipText)
$ButtonDownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe'} )

$ButtonDownloadMalwarebytes = New-Object System.Windows.Forms.Button
$ButtonDownloadMalwarebytes.Text = 'Malwarebytes'
$ButtonDownloadMalwarebytesToolTipText = "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware"
$ButtonDownloadMalwarebytes.Location = $ButtonDownloadRecuva.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL
$ButtonDownloadMalwarebytes.Height = $_BUTTON_HEIGHT
$ButtonDownloadMalwarebytes.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadMalwarebytes.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadMalwarebytes, $ButtonDownloadMalwarebytesToolTipText)
$ButtonDownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'ninite_malwarebytes_setup.exe'} )


$_TAB_DOWNLOADS_INSTALLERS.Controls.AddRange(@($GroupInstallersTools))
$GroupInstallersTools.Controls.AddRange(@($ButtonDownloadCCleaner, $ButtonDownloadDefraggler, $ButtonDownloadRecuva, $ButtonDownloadMalwarebytes))
