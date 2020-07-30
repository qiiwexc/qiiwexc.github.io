Set-Variable -Option Constant GRP_Peripherals  (New-Object System.Windows.Forms.GroupBox)
$GRP_Peripherals.Text = 'Peripherals'
$GRP_Peripherals.Height = $INT_GROUP_TOP + $INT_BTN_LONG
$GRP_Peripherals.Width = $GRP_WIDTH
$GRP_Peripherals.Location = $GRP_RAMandCPU.Location + $SHIFT_GRP_HOR_NORMAL
$TAB_DIAGNOSTICS.Controls.Add($GRP_Peripherals)

Set-Variable -Option Constant BTN_CheckKeyboard (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant LBL_CheckKeyboard (New-Object System.Windows.Forms.Label)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_CheckKeyboard, 'Open webpage with a keyboard test')

$GRP_Peripherals.Controls.AddRange(@($BTN_CheckKeyboard, $LBL_CheckKeyboard))


$BTN_CheckKeyboard.Text = 'Check keyboard'
$BTN_CheckKeyboard.Font = $BTN_FONT
$BTN_CheckKeyboard.Height = $BTN_HEIGHT
$BTN_CheckKeyboard.Width = $BTN_WIDTH
$BTN_CheckKeyboard.Location = $BTN_INIT_LOCATION
$BTN_CheckKeyboard.Add_Click( { Open-InBrowser 'www.onlinemictest.com/keyboard-test' } )

$LBL_CheckKeyboard.Location = $BTN_CheckKeyboard.Location + $SHIFT_LBL_BROWSER
$LBL_CheckKeyboard.Size = $CBOX_HardwareMonitor.Size = $CBOX_SIZE
$LBL_CheckKeyboard.Text = $TXT_OPENS_IN_BROWSER
