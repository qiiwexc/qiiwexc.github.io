# A Windows message box, over the window when it is given one. Returns the button clicked, such as 'Yes'
function Show-MessageBox {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [ValidateSet('OK', 'YesNo')][String]$Buttons = 'OK',
        [ValidateSet('Information', 'Warning')][String]$Icon = 'Information',
        [ValidateSet('None', 'OK', 'Yes', 'No')][String]$Default = 'None',
        [Object]$Owner
    )

    if ($Owner) {
        return [String][Windows.MessageBox]::Show($Owner, $Message, 'qiiwexc', $Buttons, $Icon, $Default)
    }

    return [String][Windows.MessageBox]::Show($Message, 'qiiwexc', $Buttons, $Icon, $Default)
}
