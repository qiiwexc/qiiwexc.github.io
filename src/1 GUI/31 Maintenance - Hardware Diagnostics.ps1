Set-Variable -Option Constant GRP_Hardware (New-Object System.Windows.Forms.GroupBox)
$GRP_Hardware.Text = 'Hardware Diagnostics'
$GRP_Hardware.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3 + $INT_BTN_NORMAL
$GRP_Hardware.Width = $GRP_WIDTH
$GRP_Hardware.Location = $GRP_INIT_LOCATION
$TAB_MAINTENANCE.Controls.Add($GRP_Hardware)

Set-Variable -Option Constant BTN_CheckDisk        (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant RBTN_QuickDiskCheck  (New-Object System.Windows.Forms.RadioButton)
Set-Variable -Option Constant RBTN_FullDiskCheck   (New-Object System.Windows.Forms.RadioButton)

Set-Variable -Option Constant BTN_DownloadVictoria (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_StartVictoria   (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_CheckRAM         (New-Object System.Windows.Forms.Button)

Set-Variable -Option Constant BTN_HardwareMonitor  (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_HardwareMonitor (New-Object System.Windows.Forms.CheckBox)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckDisk, 'Start (C:) disk health check')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_DownloadVictoria, 'Download Victoria HDD scanner')

(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_QuickDiskCheck, 'Perform a quick disk scan')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($RBTN_FullDiskCheck, 'Schedule a full disk scan on next restart')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_StartVictoria, $TIP_START_AFTER_DOWNLOAD)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckRAM, 'Start RAM checking utility')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HardwareMonitor, 'A utility for measuring CPU and GPU temperature, voltage and frequency')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_HardwareMonitor, $TIP_START_AFTER_DOWNLOAD)

$BTN_CheckDisk.Font = $BTN_DownloadVictoria.Font = $BTN_CheckRAM.Font = $BTN_HardwareMonitor.Font = $BTN_FONT
$BTN_CheckDisk.Height = $BTN_DownloadVictoria.Height = $BTN_CheckRAM.Height = $BTN_HardwareMonitor.Height = $BTN_HEIGHT
$BTN_CheckDisk.Width = $BTN_DownloadVictoria.Width = $BTN_CheckRAM.Width = $BTN_HardwareMonitor.Width = $BTN_WIDTH

$CBOX_StartVictoria.Checked = $RBTN_QuickDiskCheck.Checked = $True
$CBOX_StartVictoria.Size = $CBOX_SIZE
$RBTN_QuickDiskCheck.Size = $RBTN_FullDiskCheck.Size = $RBTN_SIZE
$CBOX_StartVictoria.Text = $TXT_START_AFTER_DOWNLOAD

$GRP_Hardware.Controls.AddRange(
    @($BTN_CheckDisk, $RBTN_QuickDiskCheck, $RBTN_FullDiskCheck, $BTN_DownloadVictoria,
        $CBOX_StartVictoria, $BTN_CheckRAM, $BTN_HardwareMonitor, $CBOX_HardwareMonitor)
)



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


$BTN_CheckRAM.Text = 'RAM checking utility'
$BTN_CheckRAM.Location = $BTN_DownloadVictoria.Location + $SHIFT_BTN_LONG
$BTN_CheckRAM.Add_Click( { Start-MemoryCheckTool } )


$BTN_HardwareMonitor.Text = "CPUID HWMonitor$REQUIRES_ELEVATION"
$BTN_HardwareMonitor.Location = $BTN_CheckRAM.Location + $SHIFT_BTN_NORMAL
$BTN_HardwareMonitor.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_HardwareMonitor.Checked 'http://download.cpuid.com/hwmonitor/hwmonitor_1.43.zip' } )

$CBOX_HardwareMonitor.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_HardwareMonitor.Checked = $True
$CBOX_HardwareMonitor.Size = $CBOX_SIZE
$CBOX_HardwareMonitor.Location = $BTN_HardwareMonitor.Location + $SHIFT_CBOX_EXECUTE
$CBOX_HardwareMonitor.Add_CheckStateChanged( { $BTN_HardwareMonitor.Text = "CPUID HWMonitor$(if ($CBOX_HardwareMonitor.Checked) {$REQUIRES_ELEVATION})" } )
