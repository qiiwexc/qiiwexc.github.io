$GRP_Hardware = New-Object System.Windows.Forms.GroupBox
$GRP_Hardware.Text = 'Other hardware'
$GRP_Hardware.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 5
$GRP_Hardware.Width = $GRP_WIDTH
$GRP_Hardware.Location = $GRP_HDDandRAM.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Hardware)


$BTN_HardwareMonitor = New-Object System.Windows.Forms.Button
$BTN_HardwareMonitor.Text = "CPUID HWMonitor"
$BTN_HardwareMonitor.Height = $BTN_HEIGHT
$BTN_HardwareMonitor.Width = $BTN_WIDTH
$BTN_HardwareMonitor.Location = $BTN_INIT_LOCATION
$BTN_HardwareMonitor.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HardwareMonitor, 'A utility for measuring CPU and GPU temerature, ')
$BTN_HardwareMonitor.Add_Click( {
        $DownloadedFile = Start-Download 'http://download.cpuid.com/hwmonitor/hwmonitor_1.40.zip'
        if ($CBOX_HardwareMonitor.Checked -and $DownloadedFile) { Start-File $DownloadedFile }
    } )

$CBOX_HardwareMonitor = New-Object System.Windows.Forms.CheckBox
$CBOX_HardwareMonitor.Text = $TXT_START_AFTER_DOWNLOAD
$CBOX_HardwareMonitor.Size = $CBOX_SIZE
$CBOX_HardwareMonitor.Location = $BTN_HardwareMonitor.Location + $SHIFT_CBOX_EXECUTE
(New-Object System.Windows.Forms.ToolTip).SetToolTip($CBOX_HardwareMonitor, $TIP_START_AFTER_DOWNLOAD)
$CBOX_HardwareMonitor.Add_CheckStateChanged( { $BTN_HardwareMonitor.Text = "CPUID HWMonitor$(if ($CBOX_HardwareMonitor.Checked) {$REQUIRES_ELEVATION})" } )


$BTN_StressTest = New-Object System.Windows.Forms.Button
$BTN_StressTest.Text = 'CPU Stress Test'
$BTN_StressTest.Height = $BTN_HEIGHT
$BTN_StressTest.Width = $BTN_WIDTH
$BTN_StressTest.Location = $BTN_HardwareMonitor.Location + $SHIFT_BTN_LONG
$BTN_StressTest.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_StressTest, 'Open webpage with a CPU benchmark / stress test')
$BTN_StressTest.Add_Click( { Open-InBrowser 'silver.urih.com' } )

$LBL_StressTest = New-Object System.Windows.Forms.Label
$LBL_StressTest.Text = $TXT_OPENS_IN_BROWSER
$LBL_StressTest.Size = $CBOX_SIZE
$LBL_StressTest.Location = $BTN_StressTest.Location + $SHIFT_LBL_BROWSER


$BTN_CheckKeyboard = New-Object System.Windows.Forms.Button
$BTN_CheckKeyboard.Text = 'Check keyboard'
$BTN_CheckKeyboard.Height = $BTN_HEIGHT
$BTN_CheckKeyboard.Width = $BTN_WIDTH
$BTN_CheckKeyboard.Location = $BTN_StressTest.Location + $SHIFT_BTN_LONG
$BTN_CheckKeyboard.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckKeyboard, 'Open webpage with a keyboard test')
$BTN_CheckKeyboard.Add_Click( { Open-InBrowser 'onlinemictest.com/keyboard-test' } )

$LBL_CheckKeyboard = New-Object System.Windows.Forms.Label
$LBL_CheckKeyboard.Text = $TXT_OPENS_IN_BROWSER
$LBL_CheckKeyboard.Size = $CBOX_SIZE
$LBL_CheckKeyboard.Location = $BTN_CheckKeyboard.Location + $SHIFT_LBL_BROWSER


$BTN_CheckMic = New-Object System.Windows.Forms.Button
$BTN_CheckMic.Text = 'Check microphone'
$BTN_CheckMic.Height = $BTN_HEIGHT
$BTN_CheckMic.Width = $BTN_WIDTH
$BTN_CheckMic.Location = $BTN_CheckKeyboard.Location + $SHIFT_BTN_LONG
$BTN_CheckMic.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMic, 'Open webpage with a microphone test')
$BTN_CheckMic.Add_Click( { Open-InBrowser 'onlinemictest.com' } )

$LBL_CheckMic = New-Object System.Windows.Forms.Label
$LBL_CheckMic.Text = $TXT_OPENS_IN_BROWSER
$LBL_CheckMic.Size = $CBOX_SIZE
$LBL_CheckMic.Location = $BTN_CheckMic.Location + $SHIFT_LBL_BROWSER


$BTN_CheckWebCam = New-Object System.Windows.Forms.Button
$BTN_CheckWebCam.Text = 'Check webcam'
$BTN_CheckWebCam.Height = $BTN_HEIGHT
$BTN_CheckWebCam.Width = $BTN_WIDTH
$BTN_CheckWebCam.Location = $BTN_CheckMic.Location + $SHIFT_BTN_LONG
$BTN_CheckWebCam.Font = $BTN_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWebCam, 'Open webpage with a webcam test')
$BTN_CheckWebCam.Add_Click( { Open-InBrowser 'onlinemictest.com/webcam-test' } )

$LBL_CheckWebCam = New-Object System.Windows.Forms.Label
$LBL_CheckWebCam.Text = $TXT_OPENS_IN_BROWSER
$LBL_CheckWebCam.Size = $CBOX_SIZE
$LBL_CheckWebCam.Location = $BTN_CheckWebCam.Location + $SHIFT_LBL_BROWSER


$GRP_Hardware.Controls.AddRange(@(
        $BTN_HardwareMonitor, $CBOX_HardwareMonitor, $BTN_StressTest, $LBL_StressTest,
        $BTN_CheckKeyboard, $LBL_CheckKeyboard, $BTN_CheckMic, $LBL_CheckMic, $BTN_CheckWebCam, $LBL_CheckWebCam
    ))
