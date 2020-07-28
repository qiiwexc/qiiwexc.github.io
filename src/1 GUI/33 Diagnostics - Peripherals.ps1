Set-Variable -Option Constant GRP_Peripherals  (New-Object System.Windows.Forms.GroupBox)
$GRP_Peripherals.Text = 'Peripherals'
$GRP_Peripherals.Height = $INT_GROUP_TOP + $INT_BTN_LONG * 2
$GRP_Peripherals.Width = $GRP_WIDTH
$GRP_Peripherals.Location = $GRP_RAMandCPU.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Peripherals)

Set-Variable -Option Constant BTN_CheckKeyboard (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_CheckMic      (New-Object System.Windows.Forms.Button)

Set-Variable -Option Constant LBL_CheckKeyboard (New-Object System.Windows.Forms.Label)
Set-Variable -Option Constant LBL_CheckMic      (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckKeyboard, 'Open webpage with a keyboard test')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckMic, 'Open webpage with a microphone test')

$BTN_CheckKeyboard.Font = $BTN_CheckMic.Font = $BTN_FONT
$BTN_CheckKeyboard.Height = $BTN_CheckMic.Height = $BTN_HEIGHT
$BTN_CheckKeyboard.Width = $BTN_CheckMic.Width = $BTN_WIDTH

$LBL_CheckKeyboard.Size = $LBL_CheckMic.Size = $CBOX_HardwareMonitor.Size = $CBOX_SIZE
$LBL_CheckKeyboard.Text = $LBL_CheckMic.Text = $TXT_OPENS_IN_BROWSER

$GRP_Peripherals.Controls.AddRange(@($BTN_CheckKeyboard, $LBL_CheckKeyboard, $BTN_CheckMic, $LBL_CheckMic))



$BTN_CheckKeyboard.Text = 'Check keyboard'
$BTN_CheckKeyboard.Location = $BTN_INIT_LOCATION
$BTN_CheckKeyboard.Add_Click( { Open-InBrowser 'www.onlinemictest.com/keyboard-test' } )

$LBL_CheckKeyboard.Location = $BTN_CheckKeyboard.Location + $SHIFT_LBL_BROWSER


$BTN_CheckMic.Text = 'Check microphone'
$BTN_CheckMic.Location = $BTN_CheckKeyboard.Location + $SHIFT_BTN_LONG
$BTN_CheckMic.Add_Click( { Open-InBrowser 'www.onlinemictest.com' } )

$LBL_CheckMic.Location = $BTN_CheckMic.Location + $SHIFT_LBL_BROWSER
