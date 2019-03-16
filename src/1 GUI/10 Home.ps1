$_BUTTON_WIDTH_HOME = 180

$_TAB_HOME = New-Object System.Windows.Forms.TabPage
$_TAB_HOME.Text = 'Home'
$_TAB_HOME.UseVisualStyleBackColor = $True

$ButtonSystemInformation = New-Object System.Windows.Forms.Button
$ButtonSystemInformation.Text = 'Show system information'
$ButtonSystemInformation.Height = $_BUTTON_HEIGHT
$ButtonSystemInformation.Width = $_BUTTON_WIDTH_HOME
$ButtonSystemInformation.Location = "$($_INTERVAL_NORMAL + $_INTERVAL_SHORT), $($_INTERVAL_NORMAL + $_INTERVAL_SHORT)"
$ButtonSystemInformation.Font = $_BUTTON_FONT
(New-Object System.Windows.Forms.ToolTip).SetToolTip($ButtonSystemInformation, 'Print system information to the log')
$ButtonSystemInformation.Add_Click( {PrintSystemInformation} )

$_TAB_CONTROL.Controls.AddRange(@($_TAB_HOME))
$_TAB_HOME.Controls.AddRange(@($ButtonSystemInformation))
