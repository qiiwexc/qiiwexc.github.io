$GroupDownloadsTools = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsTools.Text = 'Tools'
$GroupDownloadsTools.Height = $_INTERVAL_NORMAL + $_BUTTON_INTERVAL_SHORT * 3 + $_INTERVAL_NORMAL
$GroupDownloadsTools.Width = $GroupDownloadsActivators.Width
$GroupDownloadsTools.Location = $GroupDownloadsActivators.Location + "0, $($GroupDownloadsActivators.Height + $_INTERVAL_NORMAL)"


$ButtonDownloadSDI = New-Object System.Windows.Forms.Button
$ButtonDownloadSDI.Text = 'Snappy Driver Installer'
$ButtonDownloadSDIToolTipText = 'Download Snappy Driver Installer'
$ButtonDownloadSDI.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadSDI.Height = $_BUTTON_HEIGHT
$ButtonDownloadSDI.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadSDI.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadSDI, $ButtonDownloadSDIToolTipText)
$ButtonDownloadSDI.Add_Click( {DownloadFile 'sdi-tool.org/releases/SDI_R1811.zip'} )

$ButtonDownloadVictoria = New-Object System.Windows.Forms.Button
$ButtonDownloadVictoria.Text = 'Victoria'
$ButtonDownloadVictoriaToolTipText = 'Download Victoria HDD scanner'
$ButtonDownloadVictoria.Location = $ButtonDownloadSDI.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonDownloadVictoria.Height = $_BUTTON_HEIGHT
$ButtonDownloadVictoria.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadVictoria.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadVictoria, $ButtonDownloadVictoriaToolTipText)
$ButtonDownloadVictoria.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Victoria_4.47.zip'} )

$ButtonDownloadRufus = New-Object System.Windows.Forms.Button
$ButtonDownloadRufus.Text = 'Rufus'
$ButtonDownloadRufusToolTipText = 'Download Rufus - a bootable USB creator'
$ButtonDownloadRufus.Location = $ButtonDownloadVictoria.Location + $_BUTTON_SHIFT_VERTICAL_SHORT
$ButtonDownloadRufus.Height = $_BUTTON_HEIGHT
$ButtonDownloadRufus.Width = $_BUTTON_WIDTH_DOWNLOAD
$ButtonDownloadRufus.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRufus, $ButtonDownloadRufusToolTipText)
$ButtonDownloadRufus.Add_Click( {DownloadFile 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe'} )


$_TAB_DOWNLOADS_TOOLS.Controls.AddRange(@($GroupDownloadsTools))
$GroupDownloadsTools.Controls.AddRange(@($ButtonDownloadSDI, $ButtonDownloadVictoria, $ButtonDownloadRufus))
