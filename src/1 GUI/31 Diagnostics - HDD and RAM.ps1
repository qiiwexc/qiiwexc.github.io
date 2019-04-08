$GRP_HDDandRAM = New-Object System.Windows.Forms.GroupBox
$GRP_HDDandRAM.Text = 'HDD and RAM'
$GRP_HDDandRAM.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2 + $INT_BTN_NORMAL * 2
$GRP_HDDandRAM.Width = $GRP_WIDTH
$GRP_HDDandRAM.Location = $GRP_INIT_LOCATION
$TAB_DIAGNOSTICS.Controls.Add($GRP_HDDandRAM)


$BTN_CheckDrive = New-Object System.Windows.Forms.Button
$BTN_CheckDrive.Text = "Check (C:) drive health$REQUIRES_ELEVATION"
$BTN_CheckDrive.Height = $BTN_HEIGHT
$BTN_CheckDrive.Width = $BTN_WIDTH
$BTN_CheckDrive.Location = $BTN_INIT_LOCATION
$BTN_CheckDrive.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDrive, 'Perform a (C:) drive health check')
$BTN_CheckDrive.Add_Click( { Start-DriveCheck } )


$BTN_DownloadVictoria = New-Object System.Windows.Forms.Button
$BTN_DownloadVictoria.Text = 'Victoria (HDD scan)'
$BTN_DownloadVictoria.Height = $BTN_HEIGHT
$BTN_DownloadVictoria.Width = $BTN_WIDTH
$BTN_DownloadVictoria.Location = $BTN_CheckDrive.Location + $SHIFT_BTN_NORMAL
$BTN_DownloadVictoria.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')
$BTN_DownloadVictoria.Add_Click( {
        $FileName = Start-Download 'qiiwexc.github.io/d/Victoria.zip'
        if ($CBOX_StartVictoria.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartVictoria = New-Object System.Windows.Forms.CheckBox
$CBOX_StartVictoria.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartVictoria.Size = $CBOX_SIZE
$CBOX_StartVictoria.Location = $BTN_DownloadVictoria.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartVictoria, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartVictoria.Add_CheckStateChanged( { $BTN_DownloadVictoria.Text = "Victoria (HDD scan)$(if ($CBOX_StartVictoria.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_DownloadRecuva = New-Object System.Windows.Forms.Button
$BTN_DownloadRecuva.Text = 'Recuva (restore data)'
$BTN_DownloadRecuva.Height = $BTN_HEIGHT
$BTN_DownloadRecuva.Width = $BTN_WIDTH
$BTN_DownloadRecuva.Location = $BTN_DownloadVictoria.Location + $SHIFT_BTN_LONG
$BTN_DownloadRecuva.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadRecuva, "Download Recuva installer`rRecuva helps restore deleted files")
$BTN_DownloadRecuva.Add_Click( {
        $FileName = Start-Download 'download.ccleaner.com/rcsetup.exe'
        if ($CBOX_StartRecuva.Checked -and $FileName) { Start-File $FileName }
    } )

$CBOX_StartRecuva = New-Object System.Windows.Forms.CheckBox
$CBOX_StartRecuva.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_StartRecuva.Size = $CBOX_SIZE
$CBOX_StartRecuva.Location = $BTN_DownloadRecuva.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartRecuva, $TIP_START_AFTER_DOWNLOAD)
$CBOX_StartRecuva.Add_CheckStateChanged( { $BTN_DownloadRecuva.Text = "Recuva (restore data)$(if ($CBOX_StartRecuva.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_CheckRAM = New-Object System.Windows.Forms.Button
$BTN_CheckRAM.Text = 'RAM checking utility'
$BTN_CheckRAM.Height = $BTN_HEIGHT
$BTN_CheckRAM.Width = $BTN_WIDTH
$BTN_CheckRAM.Location = $BTN_DownloadRecuva.Location + $SHIFT_BTN_LONG
$BTN_CheckRAM.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckRAM, 'Start RAM checking utility')
$BTN_CheckRAM.Add_Click( { Start-MemoryCheckTool } )


$GRP_HDDandRAM.Controls.AddRange(@($BTN_CheckDrive, $BTN_DownloadVictoria, $CBOX_StartVictoria, $BTN_DownloadRecuva, $CBOX_StartRecuva, $BTN_CheckRAM))
