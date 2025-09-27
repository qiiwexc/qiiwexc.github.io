New-GroupBox 'Essentials'


[ScriptBlock]$BUTTON_FUNCTION = { Start-DownloadUnzipAndRun -Execute:$CHECKBOX_StartSDI.Checked '{URL_SDIO}' }
New-Button 'Snappy Driver Installer' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartSDI = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = { Install-MicrosoftOffice -Execute:$CHECKBOX_StartOfficeInstaller.Checked }
New-Button 'Office Installer+' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartOfficeInstaller = New-CheckBoxRunAfterDownload -Checked


[ScriptBlock]$BUTTON_FUNCTION = { Install-Unchecky -Execute:$CHECKBOX_StartOfficeInstaller.Checked -Silent:$CHECKBOX_SilentlyInstallUnchecky.Checked }
New-Button 'Unchecky' $BUTTON_FUNCTION

[System.Windows.Forms.CheckBox]$CHECKBOX_StartUnchecky = New-CheckBoxRunAfterDownload -Checked
$CHECKBOX_StartUnchecky.Add_CheckStateChanged( {
        $CHECKBOX_SilentlyInstallUnchecky.Enabled = $CHECKBOX_StartUnchecky.Checked
    } )

[System.Windows.Forms.CheckBox]$CHECKBOX_SilentlyInstallUnchecky = New-CheckBox 'Install silently' -Checked
