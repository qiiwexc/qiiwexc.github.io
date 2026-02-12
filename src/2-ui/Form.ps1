Set-Variable -Option Constant FORM ([Windows.Forms.Form](New-Object Windows.Forms.Form))
$FORM.Text = $HOST.UI.RawUI.WindowTitle
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = $ICON_DEFAULT
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Add_Shown( { Initialize-App } )
$FORM.Add_FormClosing( { Reset-State } )


Set-Variable -Option Constant TAB_CONTROL ([Windows.Forms.TabControl](New-Object Windows.Forms.TabControl))
$TAB_CONTROL.Location = '4, 5'


Set-Variable -Option Constant LOG ([Windows.Forms.RichTextBox](New-Object Windows.Forms.RichTextBox))
$LOG.Height = 200
$LOG.Width = $FORM_WIDTH - 9
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True


Set-Variable -Option Constant PROGRESSBAR ([Windows.Forms.ProgressBar](New-Object Windows.Forms.ProgressBar))
$PROGRESSBAR.Enabled = $False
$PROGRESSBAR.Size = "$($LOG.Width), 30"


$TAB_CONTROL.Size = "$($LOG.Width + 2), $($FORM_HEIGHT - $PROGRESSBAR.Height - $LOG.Height - 10)"

$PROGRESSBAR.Location = "$($TAB_CONTROL.Location.X), $($TAB_CONTROL.Height + 5)"
$LOG.Location = "$($PROGRESSBAR.Location.X), $($PROGRESSBAR.Location.Y + $PROGRESSBAR.Height + 1)"


$FORM.Controls.Add($TAB_CONTROL)
$FORM.Controls.Add($PROGRESSBAR)
$FORM.Controls.Add($LOG)
