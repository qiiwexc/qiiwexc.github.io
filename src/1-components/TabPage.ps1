function New-TabPage {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Text
    )

    Set-Variable -Option Constant TabPage ([Windows.Forms.TabPage](New-Object Windows.Forms.TabPage))

    $TabPage.UseVisualStyleBackColor = $True
    $TabPage.Text = $Text

    $TAB_CONTROL.Controls.Add($TabPage)

    Set-Variable -Scope Script PREVIOUS_GROUP $Null
    Set-Variable -Scope Script CURRENT_TAB ([Windows.Forms.TabPage]$TabPage)
}
