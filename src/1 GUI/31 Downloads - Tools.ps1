$GRP_DownloadTools = New-Object System.Windows.Forms.GroupBox
$GRP_DownloadTools.Text = 'Tools'
$GRP_DownloadTools.Height = $INT_NORMAL + ($BTN_INT_NORMAL + $CBOX_INT_SHORT) * 3
$GRP_DownloadTools.Width = $INT_NORMAL + $BTN_WIDTH_NORMAL + $INT_NORMAL
$GRP_DownloadTools.Location = "$INT_NORMAL, $INT_NORMAL"
$TAB_TOOLS_AND_ISO.Controls.Add($GRP_DownloadTools)


$BTN_DownloadSDI = New-Object System.Windows.Forms.Button
$BTN_DownloadSDI.Text = 'Snappy Driver Installer'
$BTN_DownloadSDI.Height = $BTN_HEIGHT
$BTN_DownloadSDI.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadSDI.Location = "$INT_NORMAL, $INT_GROUP_TOP"
$BTN_DownloadSDI.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadSDI, 'Download Snappy Driver Installer')
$BTN_DownloadSDI.Add_Click( {DownloadFile 'sdi-tool.org/releases/SDI_R1811.zip' -Execute $CBOX_ExecuteSDI.Checked} )

$CBOX_ExecuteSDI = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteSDI.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteSDI.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteSDI, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteSDI.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadVictoria = New-Object System.Windows.Forms.Button
$BTN_DownloadVictoria.Text = 'Victoria'
$BTN_DownloadVictoria.Height = $BTN_HEIGHT
$BTN_DownloadVictoria.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadVictoria.Location = $BTN_DownloadSDI.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadVictoria.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
$BTN_DownloadVictoria.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Victoria.zip' -Execute $CBOX_ExecuteVictoria.Checked} )

$CBOX_ExecuteVictoria = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteVictoria.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteVictoria.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteVictoria, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteVictoria.Size = $CBOX_SIZE_DOWNLOAD


$BTN_DownloadRufus = New-Object System.Windows.Forms.Button
$BTN_DownloadRufus.Text = 'Rufus'
$BTN_DownloadRufus.Height = $BTN_HEIGHT
$BTN_DownloadRufus.Width = $BTN_WIDTH_NORMAL
$BTN_DownloadRufus.Location = $BTN_DownloadVictoria.Location + $BTN_SHIFT_VER_NORMAL + $CBOX_SHIFT_VER_SHORT
$BTN_DownloadRufus.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRufus, 'Download Rufus - a bootable USB creator')
$BTN_DownloadRufus.Add_Click( {DownloadFile 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe' -Execute $CBOX_ExecuteRufus.Checked} )

$CBOX_ExecuteRufus = New-Object System.Windows.Forms.CheckBox
$CBOX_ExecuteRufus.Text = $TXT_EXECUTE_AFTER_DOWNLOAD
$CBOX_ExecuteRufus.Location = $BTN_DownloadRufus.Location + $BTN_SHIFT_VER_SHORT + $CBOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ExecuteRufus, $TIP_EXECUTE_AFTER_DOWNLOAD)
$CBOX_ExecuteRufus.Size = $CBOX_SIZE_DOWNLOAD


$GRP_DownloadTools.Controls.AddRange(@($BTN_DownloadSDI, $BTN_DownloadVictoria, $BTN_DownloadRufus, $CBOX_ExecuteSDI, $CBOX_ExecuteVictoria, $CBOX_ExecuteRufus))
