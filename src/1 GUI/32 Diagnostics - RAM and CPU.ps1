Set-Variable -Option Constant GRP_RAMandCPU        (New-Object System.Windows.Forms.GroupBox)
$GRP_RAMandCPU.Text = 'RAM and CPU'
$GRP_RAMandCPU.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL + $INT_BTN_LONG * 2
$GRP_RAMandCPU.Width = $GRP_WIDTH
$GRP_RAMandCPU.Location = $GRP_HDD.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_RAMandCPU)

Set-Variable -Option Constant BTN_CheckRAM         (New-Object System.Windows.Forms.Button)

Set-Variable -Option Constant BTN_HardwareMonitor  (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant CBOX_HardwareMonitor (New-Object System.Windows.Forms.CheckBox)

Set-Variable -Option Constant BTN_StressTest       (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_StressTest       (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckRAM, 'Start RAM checking utility')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HardwareMonitor, 'A utility for measuring CPU and GPU temperature, voltage and frequency')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StressTest, 'Open webpage with a CPU benchmark / stress test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_HardwareMonitor, $TIP_START_AFTER_DOWNLOAD)

$BTN_CheckRAM.Font = $BTN_HardwareMonitor.Font = $BTN_StressTest.Font = $BTN_FONT
$BTN_CheckRAM.Height = $BTN_HardwareMonitor.Height = $BTN_StressTest.Height = $BTN_HEIGHT
$BTN_CheckRAM.Width = $BTN_HardwareMonitor.Width = $BTN_StressTest.Width = $BTN_WIDTH

$GRP_RAMandCPU.Controls.AddRange(@($BTN_CheckRAM, $BTN_HardwareMonitor, $CBOX_HardwareMonitor, $BTN_StressTest, $LBL_StressTest))



$BTN_CheckRAM.Text = 'RAM checking utility'
$BTN_CheckRAM.Location = $BTN_INIT_LOCATION
$BTN_CheckRAM.Add_Click( { Start-MemoryCheckTool } )


$BTN_HardwareMonitor.Text = "CPUID HWMonitor$REQUIRES_ELEVATION"
$BTN_HardwareMonitor.Location = $BTN_CheckRAM.Location + $SHIFT_BTN_NORMAL
$BTN_HardwareMonitor.Add_Click( { Start-DownloadExtractExecute -Execute:$CBOX_HardwareMonitor.Checked 'http://download.cpuid.com/hwmonitor/hwmonitor_1.41.zip' } )

$CBOX_HardwareMonitor.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_HardwareMonitor.Checked = $True
$CBOX_HardwareMonitor.Location = $BTN_HardwareMonitor.Location + $SHIFT_CBOX_EXECUTE
$CBOX_HardwareMonitor.Add_CheckStateChanged( { $BTN_HardwareMonitor.Text = "CPUID HWMonitor$(if ($CBOX_HardwareMonitor.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_StressTest.Text = 'CPU Stress Test'
$BTN_StressTest.Location = $BTN_HardwareMonitor.Location + $SHIFT_BTN_LONG
$BTN_StressTest.Add_Click( { Open-InBrowser 'silver.urih.com' } )

$LBL_StressTest.Text = $TXT_OPENS_IN_BROWSER
$LBL_StressTest.Size = $CBOX_SIZE
$LBL_StressTest.Location = $BTN_StressTest.Location + $SHIFT_LBL_BROWSER
