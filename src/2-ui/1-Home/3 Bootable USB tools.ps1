New-Card 'Bootable USB tools'


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartVentoy.IsChecked
    $FileName = (Split-Path -Leaf '{URL_VENTOY}').Replace('-windows', '')
    Start-AsyncOperation -Sender $this { Start-DownloadUnzipAndRun '{URL_VENTOY}' $FileName -Execute:$Execute } -Variables @{
        Execute  = $Execute
        FileName = $FileName
    }
}
New-Button 'Ventoy' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartVentoy = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = {
    $Execute = $CHECKBOX_StartRufus.IsChecked
    Start-AsyncOperation -Sender $this { Start-DownloadUnzipAndRun '{URL_RUFUS}' -Execute:$Execute -Params '-g' } -Variables @{
        Execute = $Execute
    }
}
New-Button 'Rufus' $BUTTON_FUNCTION

[Windows.Controls.CheckBox]$CHECKBOX_StartRufus = New-CheckBoxRunAfterDownload -Checked
