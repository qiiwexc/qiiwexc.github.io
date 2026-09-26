function Get-SystemTheme {
    try {
        Set-Variable -Option Constant UseLightTheme ([Int](Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme'))
        return ($UseLightTheme -eq 1)
    } catch {
        return $False
    }
}

function Get-SystemAccentColors {
    param(
        [Switch]$Light
    )

    # Windows 11 fills its controls not with the accent colour itself but with a shade of it that suits the
    # theme: a darker one on light backgrounds, a lighter one on dark. AccentPalette holds the shades as RGBA,
    # lightest first: Light3, Light2, Light1, the accent colour, Dark1, Dark2, Dark3 and one more
    if ($Light) {
        Set-Variable -Option Constant ShadeIndex ([Int]4)
        Set-Variable -Option Constant DefaultShade ([String]'0067C0')
    } else {
        Set-Variable -Option Constant ShadeIndex ([Int]1)
        Set-Variable -Option Constant DefaultShade ([String]'4CC2FF')
    }

    [String]$Shade = $DefaultShade
    try {
        [Byte[]]$Palette = Get-ItemPropertyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'AccentPalette'
        if ($Palette.Length -ge 32) {
            [Int]$Offset = $ShadeIndex * 4
            $Shade = '{0:X2}{1:X2}{2:X2}' -f $Palette[$Offset], $Palette[$Offset + 1], $Palette[$Offset + 2]
        }
    } catch {
        $Shade = $DefaultShade
    }

    # Hovered and pressed, a control shows the same shade at 90% and 80% opacity over whatever is behind it
    return @{
        Accent        = "#$Shade"
        AccentHover   = "#E6$Shade"
        AccentPressed = "#CC$Shade"
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

function ConvertTo-HexColor {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Media.Color]$Color
    )

    return '#{0:X2}{1:X2}{2:X2}' -f $Color.R, $Color.G, $Color.B
}

function Get-HighContrastColors {
    # A high contrast theme is a set of system colours meant to be used in fixed pairs: text colours
    # only on the background they belong with, so hover effects that would break a pair are dropped
    Set-Variable -Option Constant Window ([String](ConvertTo-HexColor ([Windows.SystemColors]::WindowColor)))
    Set-Variable -Option Constant WindowText ([String](ConvertTo-HexColor ([Windows.SystemColors]::WindowTextColor)))
    Set-Variable -Option Constant Highlight ([String](ConvertTo-HexColor ([Windows.SystemColors]::HighlightColor)))
    Set-Variable -Option Constant HighlightText ([String](ConvertTo-HexColor ([Windows.SystemColors]::HighlightTextColor)))
    Set-Variable -Option Constant ButtonFace ([String](ConvertTo-HexColor ([Windows.SystemColors]::ControlColor)))
    Set-Variable -Option Constant GrayText ([String](ConvertTo-HexColor ([Windows.SystemColors]::GrayTextColor)))

    return [Hashtable]@{
        BgColor                  = $Window
        FgColor                  = $WindowText
        CardBgColor              = $Window
        BorderColor              = $WindowText
        ButtonBorderColor        = $WindowText
        CheckBoxBgColor          = $Window
        CheckBoxBorderColor      = $WindowText
        CheckBoxHoverColor       = $Window
        SecondaryBgColor         = $ButtonFace
        SecondaryHoverColor      = $ButtonFace
        SecondaryPressedColor    = $ButtonFace
        ButtonDisabledColor      = $ButtonFace
        ButtonTextDisabledColor  = $GrayText
        ScrollBarThumbColor      = $WindowText
        ScrollBarThumbHoverColor = $Highlight
        TabBgColor               = $Window
        TabHoverColor            = $Window
        TitleBarHoverColor       = $Highlight
        TitleBarHoverTextColor   = $HighlightText
        LogBgColor               = $Window
        LogFgColor               = $WindowText
        LogInfoColor             = $WindowText
        LogWarnColor             = $WindowText
        LogErrorColor            = $WindowText
        AccentColor              = $Highlight
        AccentHoverColor         = $Highlight
        AccentPressedColor       = $Highlight
        AccentTextColor          = $HighlightText
        CloseHoverColor          = $Highlight
        CloseHoverTextColor      = $HighlightText
    }
}

function Get-ThemeColors {
    param(
        [Switch]$Light,
        [Switch]$HighContrast
    )

    if ($HighContrast) {
        return Get-HighContrastColors
    }

    if ($Light) {
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
                TitleBarHoverColor       = '#ededed'
                TitleBarHoverTextColor   = '#000000'
                LogBgColor               = '#ffffff'
                LogFgColor               = '#000000'
                LogInfoColor             = '#0067c0'
                # Windows' own caution colour for text on a light background, 5.2:1 on white
                LogWarnColor             = '#9d5d00'
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
                TitleBarHoverColor       = '#404040'
                TitleBarHoverTextColor   = '#ffffff'
                LogBgColor               = '#0c0c0c'
                LogFgColor               = '#cccccc'
                LogInfoColor             = '#4fc3f7'
                LogWarnColor             = '#ffb74d'
                LogErrorColor            = '#ef5350'
            }
        )
    }

    Set-Variable -Option Constant AccentColors ([Hashtable](Get-SystemAccentColors -Light:$Light))
    $Colors['AccentColor'] = $AccentColors.Accent
    $Colors['AccentHoverColor'] = $AccentColors.AccentHover
    $Colors['AccentPressedColor'] = $AccentColors.AccentPressed
    $Colors['AccentTextColor'] = Get-ContrastingTextColor $AccentColors.Accent
    $Colors['CloseHoverColor'] = '#c42b1c'
    $Colors['CloseHoverTextColor'] = '#ffffff'

    return $Colors
}

function Set-ThemeResources {
    param(
        [Parameter(Position = 0, Mandatory)][Windows.Window]$Window
    )

    Set-Variable -Option Constant Colors ([Hashtable](Get-ThemeColors -Light:(Get-SystemTheme) -HighContrast:([Windows.SystemParameters]::HighContrast)))

    Set-Variable -Option Constant Converter ([Windows.Media.BrushConverter]::new())
    foreach ($Entry in $Colors.GetEnumerator()) {
        $Window.Resources[$Entry.Key] = $Converter.ConvertFromString($Entry.Value)
    }
}
