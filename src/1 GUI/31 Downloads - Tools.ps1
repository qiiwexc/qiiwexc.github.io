$GroupDownloadsTools = New-Object System.Windows.Forms.GroupBox
$GroupDownloadsTools.Text = 'Tools'
$GroupDownloadsTools.Height = $_INTERVAL_NORMAL + ($_BUTTON_INTERVAL_NORMAL + $_CHECK_BOX_INTERVAL_SHORT) * 3
$GroupDownloadsTools.Width = $_INTERVAL_NORMAL + $_BUTTON_WIDTH_NORMAL + $_INTERVAL_NORMAL
$GroupDownloadsTools.Location = "$_INTERVAL_NORMAL, $_INTERVAL_NORMAL"
$_TAB_DOWNLOADS_TOOLS.Controls.Add($GroupDownloadsTools)


$ButtonDownloadSDI = New-Object System.Windows.Forms.Button
$ButtonDownloadSDI.Text = 'Snappy Driver Installer'
$ButtonDownloadSDIToolTipText = 'Download Snappy Driver Installer'
$ButtonDownloadSDI.Location = "$_INTERVAL_NORMAL, $_INTERVAL_GROUP_TOP"
$ButtonDownloadSDI.Height = $_BUTTON_HEIGHT
$ButtonDownloadSDI.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadSDI.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadSDI, $ButtonDownloadSDIToolTipText)
$ButtonDownloadSDI.Add_Click( {DownloadFile 'sdi-tool.org/releases/SDI_R1811.zip' -Execute $CheckBoxSDIExecute.Checked} )

$CheckBoxSDIExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxSDIExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxSDIExecute.Location = $ButtonDownloadSDI.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxSDIExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxSDIExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadVictoria = New-Object System.Windows.Forms.Button
$ButtonDownloadVictoria.Text = 'Victoria'
$ButtonDownloadVictoriaToolTipText = 'Download Victoria HDD scanner'
$ButtonDownloadVictoria.Location = $ButtonDownloadSDI.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadVictoria.Height = $_BUTTON_HEIGHT
$ButtonDownloadVictoria.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadVictoria.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadVictoria, $ButtonDownloadVictoriaToolTipText)
$ButtonDownloadVictoria.Add_Click( {DownloadFile 'qiiwexc.github.io/d/Victoria.zip' -Execute $CheckBoxVictoriaExecute.Checked} )

$CheckBoxVictoriaExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxVictoriaExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxVictoriaExecute.Location = $ButtonDownloadVictoria.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxVictoriaExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxVictoriaExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$ButtonDownloadRufus = New-Object System.Windows.Forms.Button
$ButtonDownloadRufus.Text = 'Rufus'
$ButtonDownloadRufusToolTipText = 'Download Rufus - a bootable USB creator'
$ButtonDownloadRufus.Location = $ButtonDownloadVictoria.Location + $_BUTTON_SHIFT_VERTICAL_NORMAL + $_CHECK_BOX_SHIFT_VERTICAL_SHORT
$ButtonDownloadRufus.Height = $_BUTTON_HEIGHT
$ButtonDownloadRufus.Width = $_BUTTON_WIDTH_NORMAL
$ButtonDownloadRufus.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonDownloadRufus, $ButtonDownloadRufusToolTipText)
$ButtonDownloadRufus.Add_Click( {DownloadFile 'github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe' -Execute $CheckBoxRufusExecute.Checked} )

$CheckBoxRufusExecute = New-Object System.Windows.Forms.CheckBox
$CheckBoxRufusExecute.Text = $_TEXT_EXECUTE_AFTER_DOWNLOAD
$CheckBoxRufusExecute.Location = $ButtonDownloadRufus.Location + $_BUTTON_SHIFT_VERTICAL_SHORT + $_CHECK_BOX_SHIFT_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CheckBoxRufusExecute, $_TOOLTIP_EXECUTE_AFTER_DOWNLOAD)
$CheckBoxRufusExecute.Size = $_CHECK_BOX_SIZE_DOWNLOAD


$GroupDownloadsTools.Controls.AddRange(
    @($ButtonDownloadSDI, $ButtonDownloadVictoria, $ButtonDownloadRufus, $CheckBoxSDIExecute, $CheckBoxVictoriaExecute, $CheckBoxRufusExecute)
)
