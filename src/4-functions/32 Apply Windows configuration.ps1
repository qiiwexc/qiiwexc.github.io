function Set-WindowsConfiguration {
    if ($CHECKBOX_Config_Windows.Checked) {
        Set-WindowsConfiguration
    }

    if ($CHECKBOX_Config_WindowsPersonalisation.Checked) {
        Import-RegistryConfiguration $CHECKBOX_Config_WindowsPersonalisation.Text $CONFIG_WINDOWS_PERSONALISATION
    }
}
