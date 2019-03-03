$_FORM_HEIGHT = 580
$_FORM_WIDTH = 650
$_FORM_FONT_TYPE = 'Microsoft Sans Serif'

$_INTERVAL_SHORT = 5
$_INTERVAL_NORMAL = 15
$_INTERVAL_LONG = 40

$_INTERVAL_TAB_ADJUSTMENT = 4
$_INTERVAL_GROUP_TOP = 20

$_BUTTON_HEIGHT = 28
$_BUTTON_INTERVAL_SHORT = $_BUTTON_HEIGHT + $_INTERVAL_SHORT
$_BUTTON_INTERVAL_NORMAL = $_BUTTON_HEIGHT + $_INTERVAL_NORMAL
$_BUTTON_FONT = "$_FORM_FONT_TYPE, 10"


$_FORM = New-Object System.Windows.Forms.Form
$_FORM.Text = "qiiwexc v$_VERSION"
$_FORM.ClientSize = "$_FORM_WIDTH, $_FORM_HEIGHT"
$_FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\powershell.exe')
$_FORM.FormBorderStyle = 'Fixed3D'
$_FORM.StartPosition = 'CenterScreen'
$_FORM.MaximizeBox = $False
$_FORM.Top = $True
$_FORM.Add_Shown( {Startup} )


$_LOG = New-Object System.Windows.Forms.RichTextBox
$_LOG.Height = 200
$_LOG.Width = - $_INTERVAL_SHORT + $_FORM_WIDTH - $_INTERVAL_SHORT
$_LOG.Location = "$_INTERVAL_SHORT, $($_FORM_HEIGHT - $_LOG.Height - $_INTERVAL_SHORT)"
$_LOG.Font = "$_FORM_FONT_TYPE, 9"
$_LOG.ReadOnly = $True
$_FORM.Controls.Add($_LOG)


$_TAB_CONTROL = New-Object System.Windows.Forms.TabControl
$_TAB_CONTROL.Size = "$($_FORM_WIDTH - $_INTERVAL_SHORT - $_INTERVAL_TAB_ADJUSTMENT), $($_FORM_HEIGHT - $_LOG.Height - $_INTERVAL_SHORT - $_INTERVAL_TAB_ADJUSTMENT)"
$_TAB_CONTROL.Location = "$_INTERVAL_SHORT, $_INTERVAL_SHORT"
$_FORM.Controls.Add($_TAB_CONTROL)
