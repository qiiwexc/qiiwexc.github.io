function Set-LocaleSettings {
    param(
        [String][Parameter(Position = 0, Mandatory)][ValidateSet('English', 'Russian')]$Locale,
        [Collections.Generic.List[String]][Parameter(Position = 1, Mandatory)][AllowEmptyString()]$TemplateContent
    )

    $LOCALE_PARAMETERS[$Locale] | ForEach-Object {
        [String]$Placeholder = "{$($_.Key)}"
        $TemplateContent = $TemplateContent.Replace($Placeholder, $_.Value)
    }

    return $TemplateContent
}

Set-Variable -Option Constant LOCALE_PARAMETERS_ENGLISH (
    [Collections.Generic.List[Hashtable]]@(
        @{Key = 'KEYBOARD1'; Value = '0809' },
        @{Key = 'KEYBOARD2'; Value = '0426' },
        @{Key = 'KEYBOARD3'; Value = '0419' },
        @{Key = 'LOCALE1'; Value = 'en-GB' },
        @{Key = 'LOCALE2'; Value = 'lv-LV' },
        @{Key = 'LOCALE3'; Value = 'ru-RU' },
        @{Key = 'UI_LANGUAGE_FALLBACK'; Value = 'ru-RU' },
        @{Key = 'UI_LANGUAGE'; Value = 'en-US' }
    )
)

Set-Variable -Option Constant LOCALE_PARAMETERS_RUSSIAN (
    [Collections.Generic.List[Hashtable]]@(
        @{Key = 'KEYBOARD1'; Value = '0419' }
        @{Key = 'KEYBOARD2'; Value = '0426' },
        @{Key = 'KEYBOARD3'; Value = '0409' },
        @{Key = 'LOCALE1'; Value = 'ru-RU' },
        @{Key = 'LOCALE2'; Value = 'lv-LV' },
        @{Key = 'LOCALE3'; Value = 'en-US' },
        @{Key = 'UI_LANGUAGE_FALLBACK'; Value = 'en-US' },
        @{Key = 'UI_LANGUAGE'; Value = 'ru-RU' }
    )
)

Set-Variable -Option Constant LOCALE_PARAMETERS (
    [Hashtable]@{
        English = $LOCALE_PARAMETERS_ENGLISH
        Russian = $LOCALE_PARAMETERS_RUSSIAN
    }
)
