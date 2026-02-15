function Get-SystemTheme {
    try {
        Set-Variable -Option Constant UseLightTheme ([Int](Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme'))
        return ($UseLightTheme -eq 1)
    } catch {
        return $False
    }
}

function Set-ThemeResources {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Window]$Window
    )

    Set-Variable -Option Constant IsLight ([Bool](Get-SystemTheme))


    if ($IsLight) {
        Set-Variable -Option Constant Colors (
            [Hashtable]@{
                BgColor                  = '#f3f3f3'
                FgColor                  = '#000000'
                CardBgColor              = '#fbfbfb'
                BorderColor              = '#ededed'
                ButtonBorderColor        = '#d3d3d3'
                CheckBoxBgColor          = '#f5f5f5'
                CheckBoxBorderColor      = '#898989'
                CheckBoxHoverColor       = '#ececec'
                SecondaryBgColor         = '#fbfbfb'
                SecondaryHoverColor      = '#f6f6f6'
                SecondaryPressedColor    = '#f0f0f0'
                ButtonDisabledColor      = '#bfbfbf'
                ButtonTextDisabledColor  = '#ffffff'
                ScrollBarThumbColor      = '#b9b9b9'
                ScrollBarThumbHoverColor = '#8b8b8b'
                TabBgColor               = '#e8e8e8'
                TabHoverColor            = '#d8d8d8'
                LogBgColor               = '#ffffff'
                LogFgColor               = '#000000'
                LogInfoColor             = '#0067c0'
                LogWarnColor             = '#d4760a'
                LogErrorColor            = '#c42b1c'
            }
        )
    } else {
        Set-Variable -Option Constant Colors (
            [Hashtable]@{
                BgColor                  = '#202020'
                FgColor                  = '#ffffff'
                CardBgColor              = '#2b2b2b'
                BorderColor              = '#404040'
                ButtonBorderColor        = '#404040'
                CheckBoxBgColor          = '#272727'
                CheckBoxBorderColor      = '#808080'
                CheckBoxHoverColor       = '#343434'
                SecondaryBgColor         = '#393939'
                SecondaryHoverColor      = '#2a2a2a'
                SecondaryPressedColor    = '#1e1e1e'
                ButtonDisabledColor      = '#434343'
                ButtonTextDisabledColor  = '#989898'
                ScrollBarThumbColor      = '#3d3d3d'
                ScrollBarThumbHoverColor = '#4b4b4b'
                TabBgColor               = '#2b2b2b'
                TabHoverColor            = '#383838'
                LogBgColor               = '#0c0c0c'
                LogFgColor               = '#cccccc'
                LogInfoColor             = '#4fc3f7'
                LogWarnColor             = '#ffb74d'
                LogErrorColor            = '#ef5350'
            }
        )
    }

    $Colors['AccentColor'] = '#0067c0'
    $Colors['AccentHoverColor'] = '#1E88E5'
    $Colors['AccentPressedColor'] = '#3284cc'
    $Colors['CloseHoverColor'] = '#c42b1c'

    foreach ($Entry in $Colors.GetEnumerator()) {
        $Window.Resources[$Entry.Key] = [Windows.Media.BrushConverter]::new().ConvertFromString($Entry.Value)
    }
}
