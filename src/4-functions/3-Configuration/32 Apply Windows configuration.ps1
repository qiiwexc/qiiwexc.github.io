function Set-WindowsConfiguration {
    if ($CHECKBOX_Config_WindowsBase.Checked) {
        Set-WindowsBaseConfiguration
    }

    if ($CHECKBOX_Config_PowerScheme.Checked) {
        Set-PowerConfiguration
    }

    if ($CHECKBOX_Config_WindowsSearch.Checked) {
        Set-FileAssociations
    }

    if ($CHECKBOX_Config_FileAssociations.Checked) {
        Set-FileAssociations
    }

    if ($CHECKBOX_Config_WindowsPersonalisation.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_WindowsPersonalisation.Text $CONFIG_WINDOWS_PERSONALISATION
    }
}
