$GroupDownloadsInstallersTools = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsInstallersTools.Text = 'Installers: Tools'
$GroupDownloadsInstallersTools.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_NORMAL * 2 + $_BUTTON_INTERVAL_SHORT * 2 + $_INTERVAL_SHORT
$GroupDownloadsInstallersTools.Width = $GroupDownloadsInstallersSoftware.Width
$GroupDownloadsInstallersTools.Location = $GroupDownloadsInstallersSoftware.Location + "$($GroupDownloadsInstallersSoftware.Width + $_INTERVAL_NORMAL), 0"
$_TAB_DOWNLOADS.Controls.Add($GroupDownloadsInstallersTools)


$ButtonDownloadCCleaner = New-Object System.Windows.Forms.Button
$ButtonDownloadCCleaner.Text = 'CCleaner'
$ButtonDownloadCCleanerToolTipText = "Download CCleaner installer"
$ButtonDownloadCCleaner.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadCCleaner.Height = $_BUTTON_HEIGHT
$ButtonDownloadCCleaner.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadCCleaner.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadCCleaner, $ButtonDownloadCCleanerToolTipText)
$ButtonDownloadCCleaner.Add_Click( {DownloadFile 'download.ccleaner.com/ccsetup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadCCleaner)

$ButtonDownloadDefraggler = New-Object System.Windows.Forms.Button
$ButtonDownloadDefraggler.Text = 'Defraggler'
$ButtonDownloadDefragglerToolTipText = "Download Defraggler installer"
$ButtonDownloadDefraggler.Location = $ButtonDownloadCCleaner.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadDefraggler.Height = $_BUTTON_HEIGHT
$ButtonDownloadDefraggler.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadDefraggler.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadDefraggler, $ButtonDownloadDefragglerToolTipText)
$ButtonDownloadDefraggler.Add_Click( {DownloadFile 'download.ccleaner.com/dfsetup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadDefraggler)

$ButtonDownloadRecuva = New-Object System.Windows.Forms.Button
$ButtonDownloadRecuva.Text = 'Recuva'
$ButtonDownloadRecuvaToolTipText = "Download Recuva installer`rRecuva helps restore deleted files"
$ButtonDownloadRecuva.Location = $ButtonDownloadDefraggler.Location + "0, $_BUTTON_INTERVAL_SHORT"
$ButtonDownloadRecuva.Height = $_BUTTON_HEIGHT
$ButtonDownloadRecuva.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadRecuva.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRecuva, $ButtonDownloadRecuvaToolTipText)
$ButtonDownloadRecuva.Add_Click( {DownloadFile 'download.ccleaner.com/rcsetup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadRecuva)


$ButtonDownloadMalwarebytes = New-Object System.Windows.Forms.Button
$ButtonDownloadMalwarebytes.Text = 'Malwarebytes'
$ButtonDownloadMalwarebytesToolTipText = "Download Malwarebytes installer`rMalwarebytes helps remove malware and adware"
$ButtonDownloadMalwarebytes.Location = $ButtonDownloadRecuva.Location + "0, $_BUTTON_INTERVAL_NORMAL"
$ButtonDownloadMalwarebytes.Height = $_BUTTON_HEIGHT
$ButtonDownloadMalwarebytes.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadMalwarebytes.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadMalwarebytes, $ButtonDownloadMalwarebytesToolTipText)
$ButtonDownloadMalwarebytes.Add_Click( {DownloadFile 'ninite.com/malwarebytes/ninite.exe' 'ninite_malwarebytes_setup.exe'} )
$GroupDownloadsInstallersTools.Controls.Add($ButtonDownloadMalwarebytes)
