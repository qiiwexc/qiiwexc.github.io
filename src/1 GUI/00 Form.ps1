Set-Variable -Option Constant FORM (New-Object System.Windows.Forms.Form)
$FORM.Text = $HOST.UI.RawUI.WindowTitle
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


Set-Variable -Option Constant LOG (New-Object System.Windows.Forms.RichTextBox)
$LOG.Height = 200
$LOG.Width = - $INTERVAL_SHORT + $FORM_WIDTH - $INTERVAL_SHORT
$LOG.Location = "$INTERVAL_SHORT, $($FORM_HEIGHT - $LOG.Height - $INTERVAL_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True
$FORM.Controls.Add($LOG)


Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)
$TAB_CONTROL.Size = "$($LOG.Width + $INTERVAL_SHORT - 4), $($FORM_HEIGHT - $LOG.Height - $INTERVAL_SHORT - 4)"
$TAB_CONTROL.Location = "$INTERVAL_SHORT, $INTERVAL_SHORT"
$FORM.Controls.Add($TAB_CONTROL)
