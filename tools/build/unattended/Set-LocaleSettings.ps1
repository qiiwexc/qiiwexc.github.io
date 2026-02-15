function Set-LocaleSettings {
    param(
        [Parameter(Position = 0, Mandatory)][String][ValidateSet('English', 'Russian')]$Locale,
        [Parameter(Position = 1, Mandatory)][String]$TemplateContent
    )

    $LOCALE_PARAMETERS[$Locale].GetEnumerator() | ForEach-Object {
        [String]$Placeholder = "{$($_.Key)}"
        $TemplateContent = $TemplateContent.Replace($Placeholder, $_.Value)
    }

    return $TemplateContent
}

Set-Variable -Option Constant LOCALE_PARAMETERS_ENGLISH (
    [Hashtable]@{
        'KEYBOARD1'            = '0809'
        'KEYBOARD2'            = '0426'
        'KEYBOARD3'            = '0419'
        'LOCALE1'              = 'en-GB'
        'LOCALE2'              = 'lv-LV'
        'LOCALE3'              = 'ru-RU'
        'UI_LANGUAGE_FALLBACK' = 'ru-RU'
        'UI_LANGUAGE'          = 'en-US'
    }
)

Set-Variable -Option Constant LOCALE_PARAMETERS_RUSSIAN (
    [Hashtable]@{
        'KEYBOARD1'            = '0419'
        'KEYBOARD2'            = '0426'
        'KEYBOARD3'            = '0409'
        'LOCALE1'              = 'ru-RU'
        'LOCALE2'              = 'lv-LV'
        'LOCALE3'              = 'en-US'
        'UI_LANGUAGE_FALLBACK' = 'en-US'
        'UI_LANGUAGE'          = 'ru-RU'
    }
)

Set-Variable -Option Constant LOCALE_PARAMETERS (
    [Hashtable]@{
        English = $LOCALE_PARAMETERS_ENGLISH
        Russian = $LOCALE_PARAMETERS_RUSSIAN
    }
)
