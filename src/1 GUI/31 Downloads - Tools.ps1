$GRP_DownloadsTools = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadsTools.Text = 'Tools'
$GRP_DownloadsTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 3
$GRP_DownloadsTools.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_DownloadsTools.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_DOWNLOADS_TOOLS.Controls.Add($GRP_DownloadsTools)


$BTN_DownloadSDI = New-Object System.Windows.Forms.Button
$BTN_DownloadSDI.Text = 'Snappy Driver Installer'
$BTN_DownloadSDI.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadSDI.Height = $BTN_HEIGHT
$BTN_DownloadSDI.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadSDI.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadSDI, 'Download Snappy Driver Installer')
$BTN_DownloadSDI.Add_Click( {DownloadFile 'sdi-tool.org/releases/SDI_R1811.zip' -Execute $CBOX_SDIExecute.Checked} )

$CBOX_SDIExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_SDIExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_SDIExecute.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_SDIExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_SDIExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadVictoria = New-Object System.Windows.Forms.Button
$BTN_DownloadVictoria.Text = 'Victoria'
$BTN_DownloadVictoria.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadVictoria.Height = $BTN_HEIGHT
$BTN_DownloadVictoria.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadVictoria.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
$BTN_DownloadVictoria.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Victoria.zip' -Execute $CBOX_VictoriaExecute.Checked} )

$CBOX_VictoriaExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_VictoriaExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_VictoriaExecute.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_VictoriaExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_VictoriaExecute.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadRufus = New-Object System.Windows.Forms.Button
$BTN_DownloadRufus.Text = 'Rufus'
$BTN_DownloadRufus.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRufus.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRufus.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BTN_DownloadRufus.Add_Click( {DownloadFile 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe' -Execute $CBOX_RufusExecute.Checked} )

$CBOX_RufusExecute = New-Object System.Windows.Forms.CheckBox
$CBOX_RufusExecute.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_RufusExecute.Location = $BTN_DownloadRufus.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_RufusExecute, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_RufusExecute.Size = $CBOX_SIZE_DOWNLOAD


$GRP_DownloadsTools.Controls.AddRange(@($BTN_DownloadSDI, $BTN_DownloadVictoria, $BTN_DownloadRufus, $CBOX_SDIExecute, $CBOX_VictoriaExecute, $CBOX_RufusExecute))
