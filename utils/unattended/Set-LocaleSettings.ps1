function Set-LocaleSettings {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('English', 'Russian')]$Locale,
        [Parameter(Position = 1, Mandatory = $True)]$TemplateContent
    )

    $LOCALE_PARAMETERS[$Locale] | ForEach-Object { $TemplateContent = $TemplateContent.Replace("{$($_.Key)}", $_.Value) }

    return $TemplateContent
}

Set-Variable -Option Constant LOCALE_PARAMETERS_ENGLISH @(
    @{Key = 'UI_LANGUAGE'; Value = 'en-US' },
    @{Key = 'LOCALE1'; Value = 'en-GB' },
    @{Key = 'KEYBOARD1'; Value = '0809' },
    @{Key = 'LOCALE2'; Value = 'lv-LV' },
    @{Key = 'KEYBOARD2'; Value = '0426' },
    @{Key = 'LOCALE3'; Value = 'ru-RU' },
    @{Key = 'KEYBOARD3'; Value = '0419' }
)

Set-Variable -Option Constant LOCALE_PARAMETERS_RUSSIAN @(
    @{Key = 'UI_LANGUAGE'; Value = 'ru-RU' },
    @{Key = 'LOCALE1'; Value = 'ru-RU' },
    @{Key = 'KEYBOARD1'; Value = '0419' }
    @{Key = 'LOCALE2'; Value = 'lv-LV' },
    @{Key = 'KEYBOARD2'; Value = '0426' },
    @{Key = 'LOCALE3'; Value = 'en-GB' },
    @{Key = 'KEYBOARD3'; Value = '0809' }
)

Set-Variable -Option Constant LOCALE_PARAMETERS @{
    English = $LOCALE_PARAMETERS_ENGLISH
    Russian = $LOCALE_PARAMETERS_RUSSIAN
}
