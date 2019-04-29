Set-Variable GRP_HDDandRAM (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_HDDandRAM.Text = 'HDD and RAM'
$GRP_HDDandRAM.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL + $INT_BTN_LONG * 3
$GRP_HDDandRAM.Width = $GRP_WIDTH
$GRP_HDDandRAM.Location = $GRP_INIT_LOCATION
$TAB_DIAGNOSTICS.Controls.Add($GRP_HDDandRAM)

Set-Variable BTN_CheckDrive (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DownloadVictoria (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_DownloadRecuva (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckRAM (New-Object System.Windows.Forms.Button) -Option Constant

Set-Variable CBOX_ScheduleDriveCheck (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_StartVictoria (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable CBOX_StartRecuva (New-Object System.Windows.Forms.CheckBox) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDrive, 'Perform a (C:) drive health check')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`nRecuva helps restore deleted files")
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckRAM, 'Start RAM checking utility')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_ScheduleDriveCheck, 'Schedule a full drive check on next restart')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartVictoria, $TIP_START_AFTER_DOWNLOAD)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRecuva, $TIP_START_AFTER_DOWNLOAD)

$BTN_CheckDrive.Font = $BTN_DownloadVictoria.Font = $BTN_DownloadRecuva.Font = $BTN_CheckRAM.Font = $BTN_FONT
$BTN_CheckDrive.Height = $BTN_DownloadVictoria.Height = $BTN_DownloadRecuva.Height = $BTN_CheckRAM.Height = $BTN_HEIGHT
$BTN_CheckDrive.Width = $BTN_DownloadVictoria.Width = $BTN_DownloadRecuva.Width = $BTN_CheckRAM.Width = $BTN_WIDTH

$CBOX_StartVictoria.Checked = $CBOX_StartRecuva.Checked = $True
$CBOX_StartVictoria.Size = $CBOX_StartRecuva.Size = $CBOX_ScheduleDriveCheck.Size = $CBOX_SIZE
$CBOX_StartVictoria.Text = $CBOX_StartRecuva.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_HDDandRAM.Controls.AddRange(@($BTN_CheckDrive, $CBOX_ScheduleDriveCheck, $BTN_DownloadVictoria, $CBOX_StartVictoria, $BTN_DownloadRecuva, $CBOX_StartRecuva, $BTN_CheckRAM))



$BTN_CheckDrive.Text = "Check (C:) drive health$REQUIRES_ELEVATION"
$BTN_CheckDrive.Location = $BTN_INIT_LOCATION
$BTN_CheckDrive.Add_Click( { Start-DriveCheck $CBOX_ScheduleDriveCheck.Checked } )

$CBOX_ScheduleDriveCheck.Text = 'Schedule full check'
$CBOX_ScheduleDriveCheck.Location = $BTN_CheckDrive.Location + $SHIFT_CBOX_EXECUTE


$BTN_DownloadVictoria.Text = "Victoria (HDD scan)$REQUIRES_ELEVATION"
$BTN_DownloadVictoria.Location = $BTN_CheckDrive.Location + $SHIFT_BTN_LONG
$BTN_DownloadVictoria.Add_Click( { Start-DownloadExtractExecute 'qiiwexc.github.io/d/Victoria.zip' -Execute:$CBOX_StartVictoria.Checked } )

$CBOX_StartVictoria.Location = $BTN_DownloadVictoria.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartVictoria.Add_CheckStateChanged( { $BTN_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRecuva.Text = "Recuva (restore data)$REQUIRES_ELEVATION"
$BTN_DownloadRecuva.Location = $BTN_DownloadVictoria.Location + $SHIFT_BTN_LONG
$BTN_DownloadRecuva.Add_Click( { Start-DownloadExtractExecute 'ccleaner.com/recuva/download/portable/downloadfile' 'Recuva.zip' -MultiFile -Execute:$CBOX_StartRecuva.Checked } )

$CBOX_StartRecuva.Location = $BTN_DownloadRecuva.Location + $SHIFT_CBOX_EXECUTE
$CBOX_StartRecuva.Add_CheckStateChanged( { $BTN_DownloadRecuva.Text = "Recuva (restore data)$(if ($CBOX_StartRecuva.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_CheckRAM.Text = 'RAM checking utility'
$BTN_CheckRAM.Location = $BTN_DownloadRecuva.Location + $SHIFT_BTN_LONG
$BTN_CheckRAM.Add_Click( { Start-MemoryCheckTool } )
