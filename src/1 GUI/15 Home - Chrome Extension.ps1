Set-Variable -Option Constant GRP_ChromeExtensions (New-Object System.Windows.Forms.GroupBox)
$GRP_ChromeExtensions.Text = 'Chrome Extensions'
$GRP_ChromeExtensions.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 2
$GRP_ChromeExtensions.Width = $GRP_WIDTH
$GRP_ChromeExtensions.Location = $GRP_Activators.Location + "0, $($GRP_Activators.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_ChromeExtensions)

Set-Variable -Option Constant BTN_HTTPSEverywhere (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_AdBlock         (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HTTPSEverywhere, 'Automatically use HTTPS security on many sites')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_AdBlock, 'Block ads and pop-ups on websites')

$BTN_HTTPSEverywhere.Font = $BTN_AdBlock.Font = $BTN_FONT
$BTN_HTTPSEverywhere.Height = $BTN_AdBlock.Height = $BTN_HEIGHT
$BTN_HTTPSEverywhere.Width = $BTN_AdBlock.Width = $BTN_WIDTH

$GRP_ChromeExtensions.Controls.AddRange(@($BTN_HTTPSEverywhere, $BTN_AdBlock))


$BTN_HTTPSEverywhere.Text = 'HTTPS Everywhere'
$BTN_HTTPSEverywhere.Location = $BTN_INIT_LOCATION
$BTN_HTTPSEverywhere.Add_Click( { Start-Process $ChromeExe 'https://chrome.google.com/webstore/detail/gcbommkclmclpchllfjekcdonpmejbdp' } )

$BTN_AdBlock.Text = 'AdBlock'
$BTN_AdBlock.Location = $BTN_HTTPSEverywhere.Location + $SHIFT_BTN_NORMAL
$BTN_AdBlock.Add_Click( { Start-Process $ChromeExe 'https://chrome.google.com/webstore/detail/gighmmpiobklfepjocnamgkkbiglidom' } )
