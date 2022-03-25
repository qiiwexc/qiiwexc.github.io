Set-Variable -Option Constant GROUP_DownloadWindows (New-Object System.Windows.Forms.GroupBox)
$GROUP_DownloadWindows.Text = 'Windows Images'
$GROUP_DownloadWindows.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_LONG * 4
$GROUP_DownloadWindows.Width = $WIDTH_GROUP
$GROUP_DownloadWindows.Location = $GROUP_Activators.Location + $SHIFT_GROUP_HORIZONTAL
$TAB_HOME.Controls.Add($GROUP_DownloadWindows)


Set-Variable -Option Constant BUTTON_Windows11 (New-Object System.Windows.Forms.Button)
$BUTTON_Windows11.Font = $BUTTON_FONT
$BUTTON_Windows11.Height = $HEIGHT_BUTTON
$BUTTON_Windows11.Width = $WIDTH_BUTTON
$BUTTON_Windows11.Text = 'Windows 11 (v21H2)'
$BUTTON_Windows11.Location = $INITIAL_LOCATION_BUTTON
$BUTTON_Windows11.Add_Click( { Open-InBrowser $URL_WINDOWS_11 } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_Windows11)
$PREVIOUS_BUTTON = $BUTTON_Windows11


Set-Variable -Option Constant LABEL_Windows11 (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Windows11, 'Download Windows 11 (v21H2) RUS-ENG -26in1- HWID-act v2 (AIO) ISO image')
$LABEL_Windows11.Size = $CHECKBOX_SIZE
$LABEL_Windows11.Text = $TXT_OPENS_IN_BROWSER
$LABEL_Windows11.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_Windows11)


Set-Variable -Option Constant BUTTON_Windows10 (New-Object System.Windows.Forms.Button)
$BUTTON_Windows10.Font = $BUTTON_FONT
$BUTTON_Windows10.Height = $HEIGHT_BUTTON
$BUTTON_Windows10.Width = $WIDTH_BUTTON
$BUTTON_Windows10.Text = 'Windows 10 (v21H2)'
$BUTTON_Windows10.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_Windows10.Add_Click( { Open-InBrowser $URL_WINDOWS_10 } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_Windows10)
$PREVIOUS_BUTTON = $BUTTON_Windows10


Set-Variable -Option Constant LABEL_Windows10 (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Windows10, 'Download Windows 10 (v21H1) RUS-ENG x86-x64 -28in1- HWID-act (AIO) ISO image')
$LABEL_Windows10.Size = $CHECKBOX_SIZE
$LABEL_Windows10.Text = $TXT_OPENS_IN_BROWSER
$LABEL_Windows10.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_Windows10)


Set-Variable -Option Constant BUTTON_Windows7 (New-Object System.Windows.Forms.Button)
$BUTTON_Windows7.Font = $BUTTON_FONT
$BUTTON_Windows7.Height = $HEIGHT_BUTTON
$BUTTON_Windows7.Width = $WIDTH_BUTTON
$BUTTON_Windows7.Text = 'Windows 7 SP1'
$BUTTON_Windows7.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_Windows7.Add_Click( { Open-InBrowser $URL_WINDOWS_7 } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_Windows7)
$PREVIOUS_BUTTON = $BUTTON_Windows7


Set-Variable -Option Constant LABEL_Windows7 (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Windows7, 'Download Windows 7 SP1 RUS-ENG x86-x64 -18in1- Activated v10 (AIO) ISO image')
$LABEL_Windows7.Size = $CHECKBOX_SIZE
$LABEL_Windows7.Text = $TXT_OPENS_IN_BROWSER
$LABEL_Windows7.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_Windows7)


Set-Variable -Option Constant BUTTON_WindowsXP (New-Object System.Windows.Forms.Button)
$BUTTON_WindowsXP.Font = $BUTTON_FONT
$BUTTON_WindowsXP.Height = $HEIGHT_BUTTON
$BUTTON_WindowsXP.Width = $WIDTH_BUTTON
$BUTTON_WindowsXP.Text = 'Windows XP SP3 (ENG)'
$BUTTON_WindowsXP.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_LONG
$BUTTON_WindowsXP.Add_Click( { Open-InBrowser $URL_WINDOWS_XP } )
$GROUP_DownloadWindows.Controls.Add($BUTTON_WindowsXP)
$PREVIOUS_BUTTON = $BUTTON_WindowsXP


Set-Variable -Option Constant LABEL_WindowsXP (New-Object System.Windows.Forms.Label)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_WindowsXP, 'Download Windows XP SP3 (ENG) + Office 2010 SP2 (ENG) [v17.5.6] ISO image')
$LABEL_WindowsXP.Size = $CHECKBOX_SIZE
$LABEL_WindowsXP.Text = $TXT_OPENS_IN_BROWSER
$LABEL_WindowsXP.Location = $PREVIOUS_BUTTON.Location + $SHIFT_LABEL_BROWSER
$GROUP_DownloadWindows.Controls.Add($LABEL_WindowsXP)
