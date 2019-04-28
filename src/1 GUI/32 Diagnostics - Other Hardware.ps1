Set-Variable GRP_Hardware (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Hardware.Text = 'Other hardware'
$GRP_Hardware.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 5
$GRP_Hardware.Width = $GRP_WIDTH
$GRP_Hardware.Location = $GRP_HDDandRAM.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Hardware)

Set-Variable BTN_HardwareMonitor (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_StressTest (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckKeyboard (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckMic (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckWebCam (New-Object System.Windows.Forms.Button) -Option Constant

Set-Variable CBOX_HardwareMonitor (New-Object System.Windows.Forms.CheckBox) -Option Constant
Set-Variable LBL_StressTest (New-Object System.Windows.Forms.Label) -Option Constant
Set-Variable LBL_CheckKeyboard (New-Object System.Windows.Forms.Label) -Option Constant
Set-Variable LBL_CheckMic (New-Object System.Windows.Forms.Label) -Option Constant
Set-Variable LBL_CheckWebCam (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HardwareMonitor, 'A utility for measuring CPU and GPU temerature, ')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StressTest, 'Open webpage with a CPU benchmark / stress test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckKeyboard, 'Open webpage with a keyboard test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMic, 'Open webpage with a microphone test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWebCam, 'Open webpage with a webcam test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_HardwareMonitor, $TIP_START_AFTER_DOWNLOAD)

$BTN_HardwareMonitor.Font = $BTN_StressTest.Font = $BTN_CheckKeyboard.Font = $BTN_CheckMic.Font = $BTN_CheckWebCam.Font = $BTN_FONT
$BTN_HardwareMonitor.Height = $BTN_StressTest.Height = $BTN_CheckKeyboard.Height = $BTN_CheckMic.Height = $BTN_CheckWebCam.Height = $BTN_HEIGHT
$BTN_HardwareMonitor.Width = $BTN_StressTest.Width = $BTN_CheckKeyboard.Width = $BTN_CheckMic.Width = $BTN_CheckWebCam.Width = $BTN_WIDTH

$LBL_StressTest.Size = $LBL_CheckKeyboard.Size = $LBL_CheckMic.Size = $LBL_CheckWebCam.Size = $CBOX_HardwareMonitor.Size = $CBOX_SIZE
$LBL_StressTest.Text = $LBL_CheckKeyboard.Text = $LBL_CheckMic.Text = $LBL_CheckWebCam.Text = $TXT_OPENS_IN_BROWSER

$GRP_Hardware.Controls.AddRange(
    @($BTN_HardwareMonitor, $CBOX_HardwareMonitor, $BTN_StressTest, $LBL_StressTest,
        $BTN_CheckKeyboard, $LBL_CheckKeyboard, $BTN_CheckMic, $LBL_CheckMic, $BTN_CheckWebCam, $LBL_CheckWebCam)
)



$BTN_HardwareMonitor.Text = "CPUID HWMonitor"
$BTN_HardwareMonitor.Location = $BTN_INIT_LOCATION
$BTN_HardwareMonitor.Add_Click( { Start-DownloadExtractExecute 'http://download.cpuid.com/hwmonitor/hwmonitor_1.40.zip' -MultiFile -Execute:$CBOX_HardwareMonitor.Checked } )

$CBOX_HardwareMonitor.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_HardwareMonitor.Location = $BTN_HardwareMonitor.Location + $SHIFT_CBOX_EXECUTE
$CBOX_HardwareMonitor.Add_CheckStateChanged( { $BTN_HardwareMonitor.Text = "CPUID HWMonitor$(if ($CBOX_HardwareMonitor.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_StressTest.Text = 'CPU Stress Test'
$BTN_StressTest.Location = $BTN_HardwareMonitor.Location + $SHIFT_BTN_LONG
$BTN_StressTest.Add_Click( { Open-InBrowser 'silver.urih.com' } )

$LBL_StressTest.Location = $BTN_StressTest.Location + $SHIFT_LBL_BROWSER


$BTN_CheckKeyboard.Text = 'Check keyboard'
$BTN_CheckKeyboard.Location = $BTN_StressTest.Location + $SHIFT_BTN_LONG
$BTN_CheckKeyboard.Add_Click( { Open-InBrowser 'onlinemictest.com/keyboard-test' } )

$LBL_CheckKeyboard.Location = $BTN_CheckKeyboard.Location + $SHIFT_LBL_BROWSER


$BTN_CheckMic.Text = 'Check microphone'
$BTN_CheckMic.Location = $BTN_CheckKeyboard.Location + $SHIFT_BTN_LONG
$BTN_CheckMic.Add_Click( { Open-InBrowser 'onlinemictest.com' } )

$LBL_CheckMic.Location = $BTN_CheckMic.Location + $SHIFT_LBL_BROWSER


$BTN_CheckWebCam.Text = 'Check webcam'
$BTN_CheckWebCam.Location = $BTN_CheckMic.Location + $SHIFT_BTN_LONG
$BTN_CheckWebCam.Add_Click( { Open-InBrowser 'onlinemictest.com/webcam-test' } )

$LBL_CheckWebCam.Location = $BTN_CheckWebCam.Location + $SHIFT_LBL_BROWSER
