Set-Variable -Option Constant GROUP_General (New-Object System.Windows.Forms.GroupBox)
$GROUP_General.Text = 'General'
$GROUP_General.Height = $INTERVAL_GROUP_TOP + $INTERVAL_BUTTON_NORMAL * 2
$GROUP_General.Width = $WIDTH_GROUP
$GROUP_General.Location = $INITIAL_LOCATION_GROUP
$TAB_HOME.Controls.Add($GROUP_General)


Function New-Button {
    Param(
        [System.Windows.Forms.GroupBox][Parameter(Position = 0)]$Box,
        [String][Parameter(Position = 1)]$Text,
        [String][Parameter(Position = 2)]$Location,
        [Switch]$Enabled,
        [Switch]$UAC = $False,
        [String]$ToolTip
        # [Function]$Click
    )

    Set-Variable -Option Constant Button (New-Object System.Windows.Forms.Button)

    $Button.Font = $BUTTON_FONT
    $Button.Height = $HEIGHT_BUTTON
    $Button.Width = $WIDTH_BUTTON

    $Button.Enabled = $Enabled
    $Button.Location = $Location

    $Button.Text = "$(if (-not $UAC -or $IS_ELEVATED) { $Text } else { "$Text *" })"

    if ($ToolTip) { (New-Object System.Windows.Forms.ToolTip).SetToolTip($Button, $ToolTip) }

    $Button.Add_Click( { Start-Elevated } )

    $Box.Controls.Add($Button)

    Return $Button
}

$AdminButtonName = "$(if ($IS_ELEVATED) {'Running as administrator'} else {'Run as administrator'})"
$PREVIOUS_BUTTON = New-Button $GROUP_General $AdminButtonName $INITIAL_LOCATION_BUTTON -Enabled:(-not $IS_ELEVATED) -UAC -ToolTip 'Restart this utility with administrator privileges'

# Set-Variable -Option Constant BUTTON_Elevate (New-Object System.Windows.Forms.Button)
# (New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_Elevate, 'Restart this utility with administrator privileges')
# $BUTTON_Elevate.Font = $BUTTON_FONT
# $BUTTON_Elevate.Height = $HEIGHT_BUTTON
# $BUTTON_Elevate.Width = $WIDTH_BUTTON
# $BUTTON_Elevate.Text = "$(if ($IS_ELEVATED) {'Running as administrator'} else {"Run as administrator$REQUIRES_ELEVATION"})"
# $BUTTON_Elevate.Location = $INITIAL_LOCATION_BUTTON
# $BUTTON_Elevate.Enabled = -not $IS_ELEVATED
# $BUTTON_Elevate.Add_Click( { Start-Elevated } )
# $GROUP_General.Controls.Add($BUTTON_Elevate)
# $PREVIOUS_BUTTON = $BUTTON_Elevate


Set-Variable -Option Constant BUTTON_SystemInfo (New-Object System.Windows.Forms.Button)
(New-Object System.Windows.Forms.ToolTip).SetToolTip($BUTTON_SystemInfo, 'Print system information to the log')
$BUTTON_SystemInfo.Font = $BUTTON_FONT
$BUTTON_SystemInfo.Height = $HEIGHT_BUTTON
$BUTTON_SystemInfo.Width = $WIDTH_BUTTON
$BUTTON_SystemInfo.Text = 'System information'
$BUTTON_SystemInfo.Location = $PREVIOUS_BUTTON.Location + $SHIFT_BUTTON_NORMAL
$BUTTON_SystemInfo.Add_Click( { Out-SystemInfo } )
$GROUP_General.Controls.Add($BUTTON_SystemInfo)
$PREVIOUS_BUTTON = $BUTTON_Elevate
