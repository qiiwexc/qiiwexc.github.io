Set-Variable -Option Constant GROUP_ChromeExtensions (New-Object System.Windows.Forms.GroupBox)
$GROUP_ChromeExtensions.Text = 'Chrome Extensions'
$GROUP_ChromeExtensions.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 3
$GROUP_ChromeExtensions.Width = $WIDTH_GROUP
$GROUP_ChromeExtensions.Location = $GROUP_Activators.Location + "0, $($GROUP_Activators.Height + $INTERVAL_NORMAL)"
$TAB_HOME.Controls.Add($GROUP_ChromeExtensions)
$GROUP = $GROUP_ChromeExtensions


Set-Variable -Option Constant BUTTON_HTTPSEverywhere (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_HTTPSEverywhere, 'Automatically use HTTPS security on many sites')
$BUTTON_HTTPSEverywhere.Enabled = Test-Path $PATH_CHROME_EXE
$BUTTON_HTTPSEverywhere.Font = $BUTTON_FONT
$BUTTON_HTTPSEverywhere.Height = $HEIGHT_BUTTON
$BUTTON_HTTPSEverywhere.Width = $WIDTH_BUTTON
$BUTTON_HTTPSEverywhere.Text = 'HTTPS Everywhere'
$BUTTON_HTTPSEverywhere.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_HTTPSEverywhere.Add_Click( { Start-Process $PATH_CHROME_EXE $URL_CHROME_HTTPS } )
$GROUP_ChromeExtensions.Controls.Add($BUTTON_HTTPSEverywhere)
$PREVIOUS_BUTTON = $BUTTON_HTTPSEverywhere


Set-Variable -Option Constant BUTTON_AdBlock (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_AdBlock, 'Block ads and pop-ups on websites')
$BUTTON_AdBlock.Enabled = Test-Path $PATH_CHROME_EXE
$BUTTON_AdBlock.Font = $BUTTON_FONT
$BUTTON_AdBlock.Height = $HEIGHT_BUTTON
$BUTTON_AdBlock.Width = $WIDTH_BUTTON
$BUTTON_AdBlock.Text = 'AdBlock'
$BUTTON_AdBlock.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_AdBlock.Add_Click( { Start-Process $PATH_CHROME_EXE $URL_CHROME_ADBLOCK } )
$GROUP_ChromeExtensions.Controls.Add($BUTTON_AdBlock)
$PREVIOUS_BUTTON = $BUTTON_AdBlock


Set-Variable -Option Constant BUTTON_YouTube_Dislike (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_YouTube_Dislike, 'Return YouTube Dislike restores the ability to see dislikes on YouTube')
$BUTTON_YouTube_Dislike.Enabled = Test-Path $PATH_CHROME_EXE
$BUTTON_YouTube_Dislike.Font = $BUTTON_FONT
$BUTTON_YouTube_Dislike.Height = $HEIGHT_BUTTON
$BUTTON_YouTube_Dislike.Width = $WIDTH_BUTTON
$BUTTON_YouTube_Dislike.Text = 'Return YouTube Dislike'
$BUTTON_YouTube_Dislike.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_YouTube_Dislike.Add_Click( { Start-Process $PATH_CHROME_EXE $URL_CHROME_YOUTUBE } )
$GROUP_ChromeExtensions.Controls.Add($BUTTON_YouTube_Dislike)
$PREVIOUS_BUTTON = $BUTTON_YouTube_Dislike
