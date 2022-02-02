Set-Variable -Option Constant GRP_ChromeExtensions (New-Object System.Windows.Forms.GroupBox)
$GRP_ChromeExtensions.Text = 'Chrome Extensions'
$GRP_ChromeExtensions.Height = $INT_GROUP_TOP + $INT_BTN_NORMAL * 3
$GRP_ChromeExtensions.Width = $GRP_WIDTH
$GRP_ChromeExtensions.Location = $GRP_Activators.Location + "0, $($GRP_Activators.Height + $INT_NORMAL)"
$TAB_HOME.Controls.Add($GRP_ChromeExtensions)

Set-Variable -Option Constant BTN_HTTPSEverywhere (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_AdBlock         (New-Object System.Windows.Forms.Button)
Set-Variable -Option Constant BTN_YouTube_Dislike (New-Object System.Windows.Forms.Button)

(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_HTTPSEverywhere, 'Automatically use HTTPS security on many sites')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_AdBlock, 'Block ads and pop-ups on websites')
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BTN_YouTube_Dislike, 'Return YouTube Dislike restores the ability to see dislikes on YouTube')

$BTN_HTTPSEverywhere.Font = $BTN_AdBlock.Font = $BTN_YouTube_Dislike.Font = $BTN_FONT
$BTN_HTTPSEverywhere.Height = $BTN_AdBlock.Height = $BTN_YouTube_Dislike.Height = $BTN_HEIGHT
$BTN_HTTPSEverywhere.Width = $BTN_AdBlock.Width = $BTN_YouTube_Dislike.Width = $BTN_WIDTH

$GRP_ChromeExtensions.Controls.AddRange(@($BTN_YouTube_Dislike, $BTN_HTTPSEverywhere, $BTN_AdBlock))


$BTN_HTTPSEverywhere.Text = 'HTTPS Everywhere'
$BTN_HTTPSEverywhere.Location = $BTN_INIT_LOCATION
$BTN_HTTPSEverywhere.Add_Click( { Start-Process $ChromeExe 'bit.ly/HTTPS_Everywhere' } )

$BTN_AdBlock.Text = 'AdBlock'
$BTN_AdBlock.Location = $BTN_HTTPSEverywhere.Location + $SHIFT_BTN_NORMAL
$BTN_AdBlock.Add_Click( { Start-Process $ChromeExe 'bit.ly/AdBlock_Chrome_Store' } )

$BTN_YouTube_Dislike.Text = 'Return YouTube Dislike'
$BTN_YouTube_Dislike.Location = $BTN_AdBlock.Location + $SHIFT_BTN_NORMAL
$BTN_YouTube_Dislike.Add_Click( { Start-Process $ChromeExe 'chrome.google.com/webstore/detail/gebbhagfogifgggkldgodflihgfeippi' } )
