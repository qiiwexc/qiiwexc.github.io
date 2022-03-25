Set-Variable -Option Constant FORM (New-Object System.Windows.Forms.Form)
$FORM.Text = $HOST.UI.RawUI.WindowTitle
$FORM.ClientSize = "$WIDTH_FORM, $HEIGHT_FORM"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


Set-Variable -Option Constant LOG (New-Object System.Windows.Forms.RichTextBox)
$LOG.Height = 200
$LOG.Width = - $INTERVAL_SHORT + $WIDTH_FORM - $INTERVAL_SHORT
$LOG.Location = "$INTERVAL_SHORT, $($HEIGHT_FORM - $LOG.Height - $INTERVAL_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True
$FORM.Controls.Add($LOG)


Set-Variable -Option Constant TAB_CONTROL (New-Object System.Windows.Forms.TabControl)
$TAB_CONTROL.Size = "$($LOG.Width + $INTERVAL_SHORT - 4), $($HEIGHT_FORM - $LOG.Height - $INTERVAL_SHORT - 4)"
$TAB_CONTROL.Location = "$INTERVAL_SHORT, $INTERVAL_SHORT"
$FORM.Controls.Add($TAB_CONTROL)


Set-Variable -Option Constant TAB_HOME (New-Object System.Windows.Forms.TabPage)
$TAB_HOME.Text = 'Home'
$TAB_HOME.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_HOME)

Set-Variable -Option Constant TAB_DOWNLOADS (New-Object System.Windows.Forms.TabPage)
$TAB_DOWNLOADS.Text = 'Downloads'
$TAB_DOWNLOADS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_DOWNLOADS)

Set-Variable -Option Constant TAB_MAINTENANCE (New-Object System.Windows.Forms.TabPage)
$TAB_MAINTENANCE.Text = 'Maintenance'
$TAB_MAINTENANCE.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_MAINTENANCE)
