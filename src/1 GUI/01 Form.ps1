Set-Variable FORM (New-Object System.Windows.Forms.Form) -Option Constant
Set-Variable LOG (New-Object System.Windows.Forms.RichTextBox) -Option Constant
Set-Variable TAB_CONTROL (New-Object System.Windows.Forms.TabControl) -Option Constant

Set-Variable TAB_HOME (New-Object System.Windows.Forms.TabPage) -Option Constant
Set-Variable TAB_INSTALLERS (New-Object System.Windows.Forms.TabPage) -Option Constant
Set-Variable TAB_DIAGNOSTICS (New-Object System.Windows.Forms.TabPage) -Option Constant
Set-Variable TAB_MAINTENANCE (New-Object System.Windows.Forms.TabPage) -Option Constant

$TAB_HOME.UseVisualStyleBackColor = $TAB_INSTALLERS.UseVisualStyleBackColor = $TAB_DIAGNOSTICS.UseVisualStyleBackColor = $TAB_MAINTENANCE.UseVisualStyleBackColor = $True

$TAB_CONTROL.Controls.AddRange(@($TAB_HOME, $TAB_INSTALLERS, $TAB_DIAGNOSTICS, $TAB_MAINTENANCE))
$FORM.Controls.AddRange(@($LOG, $TAB_CONTROL))



$FORM.Text = "qiiwexc v$VERSION"
$FORM.ClientSize = "$FORM_WIDTH, $FORM_HEIGHT"
$FORM.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + '\PowerShell.exe')
$FORM.FormBorderStyle = 'Fixed3D'
$FORM.StartPosition = 'CenterScreen'
$FORM.MaximizeBox = $False
$FORM.Top = $True
$FORM.Add_Shown( { Initialize-Startup } )
$FORM.Add_FormClosing( { Reset-StateOnExit } )


$LOG.Height = 200
$LOG.Width = - $INT_SHORT + $FORM_WIDTH - $INT_SHORT
$LOG.Location = "$INT_SHORT, $($FORM_HEIGHT - $LOG.Height - $INT_SHORT)"
$LOG.Font = "$FONT_NAME, 9"
$LOG.ReadOnly = $True


$TAB_CONTROL.Size = "$($LOG.Width + $INT_SHORT - $INT_TAB_ADJ), $($FORM_HEIGHT - $LOG.Height - $INT_SHORT - $INT_TAB_ADJ)"
$TAB_CONTROL.Location = "$INT_SHORT, $INT_SHORT"


$TAB_HOME.Text = 'Home'
$TAB_INSTALLERS.Text = 'Downloads'
$TAB_DIAGNOSTICS.Text = 'Diagnostics'
$TAB_MAINTENANCE.Text = 'Maintenance'
