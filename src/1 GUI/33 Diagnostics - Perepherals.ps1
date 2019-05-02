Set-Variable GRP_Perepherals (New-Object System.Windows.Forms.GroupBox) -Option Constant
$GRP_Perepherals.Text = 'Perepherals'
$GRP_Perepherals.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 3
$GRP_Perepherals.Width = $GRP_WIDTH
$GRP_Perepherals.Location = $GRP_RAMandCPU.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Perepherals)

Set-Variable BTN_CheckKeyboard (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckMic (New-Object System.Windows.Forms.Button) -Option Constant
Set-Variable BTN_CheckWebCam (New-Object System.Windows.Forms.Button) -Option Constant

Set-Variable LBL_CheckKeyboard (New-Object System.Windows.Forms.Label) -Option Constant
Set-Variable LBL_CheckMic (New-Object System.Windows.Forms.Label) -Option Constant
Set-Variable LBL_CheckWebCam (New-Object System.Windows.Forms.Label) -Option Constant

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckKeyboard, 'Open webpage with a keyboard test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMic, 'Open webpage with a microphone test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckWebCam, 'Open webpage with a webcam test')

$BTN_CheckKeyboard.Font = $BTN_CheckMic.Font = $BTN_CheckWebCam.Font = $BTN_FONT
$BTN_CheckKeyboard.Height = $BTN_CheckMic.Height = $BTN_CheckWebCam.Height = $BTN_HEIGHT
$BTN_CheckKeyboard.Width = $BTN_CheckMic.Width = $BTN_CheckWebCam.Width = $BTN_WIDTH

$LBL_CheckKeyboard.Size = $LBL_CheckMic.Size = $LBL_CheckWebCam.Size = $CBOX_HardwareMonitor.Size = $CBOX_SIZE
$LBL_CheckKeyboard.Text = $LBL_CheckMic.Text = $LBL_CheckWebCam.Text = $TXT_OPENS_IN_BROWSER

$GRP_Perepherals.Controls.AddRange(@($BTN_CheckKeyboard, $LBL_CheckKeyboard, $BTN_CheckMic, $LBL_CheckMic, $BTN_CheckWebCam, $LBL_CheckWebCam))



$BTN_CheckKeyboard.Text = 'Check keyboard'
$BTN_CheckKeyboard.Location = $BTN_INIT_LOCATION
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
