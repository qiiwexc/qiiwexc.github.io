Set-Variable -Option Constant GRP_HDD (New-Object System.Windows.Forms.GroupBox)
$GRP_HDD.Text = 'HDD'
$GRP_HDD.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_HDD.Width = $GRP_WIDTH
$GRP_HDD.Location = $GRP_INIT_LOCATION
$TAB_DIAGNOSTICS.Controls.Add($GRP_HDD)

Set-Variable -Option Constant BTN_CheckDisk        (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant RBTN_QuickDiskCheck  (New-Object System.Windows.Forms.RadioButton)
Set-Variable -Option Constant RBTN_FullDiskCheck   (New-Object System.Windows.Forms.RadioButton)

Set-Variable -Option Constant BTN_DownloadVictoria (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartVictoria   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_DownloadRecuva   (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartRecuva     (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDisk, 'Start (C:) disk health check')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`nRecuva helps restore deleted files")

(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_QuickDiskCheck, 'Perform a quick disk scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_FullDiskCheck, 'Schedule a full disk scan on next restart')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartVictoria, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRecuva, $TIP_START_AFTER_DOWNLOAD)

$BTN_CheckDisk.Font = $BTN_DownloadVictoria.Font = $BTN_DownloadRecuva.Font = $BTN_FONT
$BTN_CheckDisk.Height = $BTN_DownloadVictoria.Height = $BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_CheckDisk.Width = $BTN_DownloadVictoria.Width = $BTN_DownloadRecuva.Width = $BTN_WIDTH

$CBOX_StartVictoria.Checked = $CBOX_StartRecuva.Checked = $RBTN_QuickDiskCheck.Checked = $True
$CBOX_StartVictoria.Size = $CBOX_StartRecuva.Size = $CBOX_SIZE
$RBTN_QuickDiskCheck.Size = $RBTN_FullDiskCheck.Size = $RBTN_SIZE
$CBOX_StartVictoria.Text = $CBOX_StartRecuva.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_HDD.Controls.AddRange(@($BTN_CheckDisk, $RBTN_QuickDiskCheck, $RBTN_FullDiskCheck, $BTN_DownloadVictoria, $CBOX_StartVictoria, $BTN_DownloadRecuva, $CBOX_StartRecuva))



$BTN_CheckDisk.Text = "Check (C:) disk health$REQUIRES_ELEVATION"
$BTN_CheckDisk.Location = $BTN_INIT_LOCATION
$BTN_CheckDisk.Add_Click( { Start-DiskCheck $RBTN_FullDiskCheck.Checked } )

$RBTN_QuickDiskCheck.Text = 'Quick scan'
$RBTN_QuickDiskCheck.Location = $BTN_CheckDisk.Location + $SHIFT_RBTN_QUICK_SCAN

$RBTN_FullDiskCheck.Text = 'Full scan'
$RBTN_FullDiskCheck.Location = $RBTN_QuickDiskCheck.Location + $SHIFT_RBTN_FULL_SCAN


$BTN_DownloadVictoria.Text = "Victoria (HDD scan)$REQUIRES_ELEVATION"
$BTN_DownloadVictoria.Location = $BTN_CheckDisk.Location + $SHIFT_BTN_LONG
$BTN_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartVictoria.Checked 'hdd.by/Victoria/Victoria535.zip' } )

$CBOX_StartVictoria.Location = $BTN_DownloadVictoria.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartVictoria.Add_CheckStateChanged( { $BTN_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRecuva.Text = "Recuva (restore data)$REQUIRES_ELEVATION"
$BTN_DownloadRecuva.Location = $BTN_DownloadVictoria.Location + $SHIFT_BTN_LONG
$BTN_DownloadRecuva.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_StartRecuva.Checked 'download.ccleaner.com/rcsetup.exe' } )

$CBOX_StartRecuva.Location = $BTN_DownloadRecuva.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRecuva.Add_CheckStateChanged( { $BTN_DownloadRecuva.Text = "Recuva (restore data)$(if ($CBOX_StartRecuva.Checked) {$REQUIRES_ELEVATION})" } )
