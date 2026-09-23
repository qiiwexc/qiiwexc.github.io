New-Card 'Bootable USB tools'


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartVentoy.IsChecked
    $FileName = (Split-Path -Leaf '{URL_VENTOY}').Replace('-windows', '')
    Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_VENTOY}' $FileName -Sha256 '{SHA256_VENTOY}' -Execute:$Execute } -Variables @{
        Execute  = $Execute
        FileName = $FileName
    }
}
New-Button 'Ventoy' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartRufus.IsChecked
    Start-AsyncOperation -Button $this { Start-DownloadUnzipAndRun '{URL_RUFUS}' -Sha256 '{SHA256_RUFUS}' -Execute:$Execute -Params '-g' } -Variables @{
        Execute = $Execute
    }
}
New-Button 'Rufus' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Checked
