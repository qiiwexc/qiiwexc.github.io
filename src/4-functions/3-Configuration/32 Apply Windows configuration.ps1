function Set-WindowsConfiguration {
    if ($CHECKBOX_Config_WindowsBase.Checked) {
        Set-WindowsBaseConfiguration $CHECKBOX_Config_WindowsBase.Text
    }

    if ($CHECKBOX_Config_PowerScheme.Checked) {
        Set-PowerSchemeConfiguration
    }

    if ($CHECKBOX_Config_WindowsSearch.Checked) {
        Set-SearchConfiguration $CHECKBOX_Config_WindowsSearch.Text
    }

    if ($CHECKBOX_Config_FileAssociations.Checked) {
        Set-FileAssociations
    }

    if ($CHECKBOX_Config_WindowsPersonalisation.Checked) {
        Set-WindowsPersonalisationConfig $CHECKBOX_Config_WindowsPersonalisation.Text
    }
}
