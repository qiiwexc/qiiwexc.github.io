function Get-SystemTheme {
    try {
        Set-Variable -Option Constant UseLightTheme ([Int](Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme'))
        return ($UseLightTheme -eq 1)
    } catch {
        return $False
    }
}

function Get-SystemAccentColors {
    [Hashtable]$Defaults = @{
        Accent        = '#0067c0'
        AccentHover   = '#1975c9'
        AccentPressed = '#3284cc'
    }
    try {
        [Byte[]]$Palette = Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'AccentPalette'
        if ($Palette.Length -lt 20) { return $Defaults }
        return @{
            Accent        = '#{0:X2}{1:X2}{2:X2}' -f $Palette[12], $Palette[13], $Palette[14]
            AccentHover   = '#{0:X2}{1:X2}{2:X2}' -f $Palette[8], $Palette[9], $Palette[10]
            AccentPressed = '#{0:X2}{1:X2}{2:X2}' -f $Palette[16], $Palette[17], $Palette[18]
        }
    } catch {
        return $Defaults
    }
}

function Get-ContrastingTextColor {
    param(
        [Parameter(Position = 0, Mandatory)][String]$BackgroundColor
    )

    # WCAG relative luminance of a '#RRGGBB' colour: above ~0.18, black text has the higher contrast,
    # so light accents (yellow, light green) get dark text, as Windows itself does
    [Double[]]$Channels = @(1, 3, 5) | ForEach-Object {
        [Double]$Value = [Convert]::ToInt32($BackgroundColor.Substring($_, 2), 16) / 255
        if ($Value -le 0.03928) { $Value / 12.92 } else { [Math]::Pow(($Value + 0.055) / 1.055, 2.4) }
    }
    Set-Variable -Option Constant Luminance ([Double](0.2126 * $Channels[0] + 0.7152 * $Channels[1] + 0.0722 * $Channels[2]))

    if ($Luminance -gt 0.179) {
        return '#000000'
    } else {
        return '#ffffff'
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

    Set-Variable -Option Constant AccentColors ([Hashtable](Get-SystemAccentColors))
    $Colors['AccentColor'] = $AccentColors.Accent
    $Colors['AccentHoverColor'] = $AccentColors.AccentHover
    $Colors['AccentPressedColor'] = $AccentColors.AccentPressed
    $Colors['AccentTextColor'] = Get-ContrastingTextColor $AccentColors.Accent
    $Colors['CloseHoverColor'] = '#c42b1c'

    Set-Variable -Option Constant Converter ([Windows.Media.BrushConverter]::new())
    foreach ($Entry in $Colors.GetEnumerator()) {
        $Window.Resources[$Entry.Key] = $Converter.ConvertFromString($Entry.Value)
    }
}
