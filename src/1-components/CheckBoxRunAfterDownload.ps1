function New-CheckBoxRunAfterDownload {
    param(
        [Switch]$Disabled,
        [Switch]$Checked
    )

    return New-CheckBox 'Start after download' -Disabled $Disabled -Checked $Checked
}
