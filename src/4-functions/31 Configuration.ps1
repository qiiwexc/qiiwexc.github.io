function Set-Configuration {
    if ($CHECKBOX_Config_VLC.Checked) {
        Set-VlcConfiguration
    }

    if ($CHECKBOX_Config_qBittorrent.Checked) {
        Set-qBittorrentConfiguration
    }

    if ($CHECKBOX_Config_7zip.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_7zip.Text $CONFIG_7ZIP
    }

    if ($CHECKBOX_Config_TeamViewer.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_TeamViewer.Text $CONFIG_TEAMVIEWER
    }

    if ($CHECKBOX_Config_Edge.Checked) {
        Set-MicrosoftEdgeConfiguration
    }

    if ($CHECKBOX_Config_Chrome.Checked) {
        Set-GoogleChromeConfiguration
    }

    if ($CHECKBOX_Config_Windows.Checked) {
        Set-WindowsConfiguration
    }

    if ($CHECKBOX_Config_WindowsPersonalisation.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_WindowsPersonalisation.Text $CONFIG_WINDOWS_PERSONALISATION
    }
}
