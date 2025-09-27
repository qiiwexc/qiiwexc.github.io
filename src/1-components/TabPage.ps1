function New-TabPage {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Text
    )

    Set-Variable -Option Constant TabPage (New-Object System.Windows.Forms.TabPage)

    $TabPage.UseVisualStyleBackColor = $True
    $TabPage.Text = $Text

    $TAB_CONTROL.Controls.Add($TabPage)

    Set-Variable -Scope Script PREVIOUS_GROUP $Null
    Set-Variable -Scope Script CURRENT_TAB $TabPage
}
