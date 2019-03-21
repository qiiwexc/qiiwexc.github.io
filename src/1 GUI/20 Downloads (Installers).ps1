$TAB_INSTALLERS = New-Object System.Windows.Forms.TabPage
$TAB_INSTALLERS.Text = 'Downloads: Installers'
$TAB_INSTALLERS.UseVisualStyleBackColor = $True
$TAB_CONTROL.Controls.Add($TAB_INSTALLERS)


$CBOX_WIDTH_DOWNLOAD = 145
$CBOX_SIZE_DOWNLOAD = "$($CBOX_WIDTH_DOWNLOAD), $($CBOX_HEIGHT)"
$CBOX_SHIFT_EXECUTE = '12, -5'

$LBL_SHIFT_BROWSER = '22, -3'


$TXT_AV_WARNING = "!! THIS FILE MAY TRIGGER ANTI-VIRUS FALSE POSITIVE !!`n!! IT IS RECOMMENDED TO DISABLE A/V SOFTWARE FOR DOWNLOAD AND SUBESEQUENT USE OF THIS FILE !!"
$TXT_EXECUTE_AFTER_DOWNLOAD = 'Execute after download'
$TXT_INSTALL_SILENTLY = 'Install silently'
$TXT_OPENS_IN_BROWSER = 'Opens in the browser'

$TIP_EXECUTE_AFTER_DOWNLOAD = "Execute after download has finished`nIf download is a ZIP file, it will get extracted first"
$TIP_INSTALL_SILENTLY = 'Perform silent installation with no prompts'
