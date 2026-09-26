BeforeAll {
    Add-Type -AssemblyName PresentationFramework

    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    function Get-ContrastRatio {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Foreground,
            [Parameter(Position = 1, Mandatory)][String]$Background
        )

        [Double[]]$Luminances = @($Foreground, $Background) | ForEach-Object {
            [String]$Hex = $_
            [Double[]]$Channels = @(1, 3, 5) | ForEach-Object {
                [Double]$Value = [Convert]::ToInt32($Hex.Substring($_, 2), 16) / 255
                if ($Value -le 0.03928) { $Value / 12.92 } else { [Math]::Pow(($Value + 0.055) / 1.055, 2.4) }
            }
            0.2126 * $Channels[0] + 0.7152 * $Channels[1] + 0.0722 * $Channels[2]
        }

        return ([Math]::Max($Luminances[0], $Luminances[1]) + 0.05) / ([Math]::Min($Luminances[0], $Luminances[1]) + 0.05)
    }
}

Describe 'Get-SystemAccentColors' {
    BeforeAll {
        # The default blue accent's palette, as Windows writes it: Light3 to Dark3 and one more, as RGBA
        Set-Variable -Option Constant TestPalette ([Byte[]]@(
                0x99, 0xEB, 0xFF, 0x00, 0x4C, 0xC2, 0xFF, 0x00, 0x00, 0x91, 0xF8, 0x00, 0x00, 0x78, 0xD4, 0x00,
                0x00, 0x67, 0xC0, 0x00, 0x00, 0x3E, 0x92, 0x00, 0x00, 0x1A, 0x68, 0x00, 0xF7, 0x63, 0x0C, 0x00
            ))
    }

    It 'Should use the <Shade> shade of the accent colour in the <Theme> theme' -ForEach @(
        @{ Theme = 'light'; Shade = 'Dark1'; Expected = '0067C0' }
        @{ Theme = 'dark'; Shade = 'Light2'; Expected = '4CC2FF' }
    ) {
        Mock Get-ItemPropertyValue { return $TestPalette }

        [Hashtable]$Colors = Get-SystemAccentColors -Light:($Theme -eq 'light')

        $Colors.Accent | Should -BeExactly "#$Expected"
        $Colors.AccentHover | Should -BeExactly "#E6$Expected"
        $Colors.AccentPressed | Should -BeExactly "#CC$Expected"
    }

    It 'Should fall back to the default blue in the <Theme> theme when the palette is <Case>' -ForEach @(
        @{ Theme = 'light'; Case = 'too short'; Palette = [Byte[]]@(0x00, 0x78, 0xD4, 0x00); Expected = '0067C0' }
        @{ Theme = 'dark'; Case = 'too short'; Palette = [Byte[]]@(0x00, 0x78, 0xD4, 0x00); Expected = '4CC2FF' }
        @{ Theme = 'light'; Case = 'missing'; Palette = $Null; Expected = '0067C0' }
        @{ Theme = 'dark'; Case = 'missing'; Palette = $Null; Expected = '4CC2FF' }
    ) {
        if ($Palette) {
            Mock Get-ItemPropertyValue { return $Palette }
        } else {
            Mock Get-ItemPropertyValue { throw 'Property AccentPalette does not exist' }
        }

        [Hashtable]$Colors = Get-SystemAccentColors -Light:($Theme -eq 'light')

        $Colors.Accent | Should -BeExactly "#$Expected"
        $Colors.AccentHover | Should -BeExactly "#E6$Expected"
        $Colors.AccentPressed | Should -BeExactly "#CC$Expected"
    }
}

Describe 'Get-ContrastingTextColor' {
    It 'Should pick <Expected> text on <Background>' -ForEach @(
        @{ Background = '#0067c0'; Expected = '#ffffff' } # Default Windows blue, light theme shade
        @{ Background = '#4CC2FF'; Expected = '#000000' } # Default Windows blue, dark theme shade
        @{ Background = '#FFB900'; Expected = '#000000' } # Windows yellow accent
        @{ Background = '#00CC6A'; Expected = '#000000' } # Windows light green accent
        @{ Background = '#C42B1C'; Expected = '#ffffff' } # Red
        @{ Background = '#000000'; Expected = '#ffffff' }
        @{ Background = '#ffffff'; Expected = '#000000' }
    ) {
        Get-ContrastingTextColor $Background | Should -BeExactly $Expected
    }
}

Describe 'Get-ThemeColors' {
    It 'Should define the same resources in every theme, so none is left unresolved' {
        [String[]]$LightKeys = @((Get-ThemeColors -Light).Keys | Sort-Object)

        @((Get-ThemeColors).Keys | Sort-Object) | Should -BeExactly $LightKeys
        @((Get-ThemeColors -HighContrast).Keys | Sort-Object) | Should -BeExactly $LightKeys
    }

    It 'Should keep log text readable in the <Theme> theme: <Key>' -ForEach @(
        @{ Theme = 'light'; Key = 'LogFgColor' }
        @{ Theme = 'light'; Key = 'LogInfoColor' }
        @{ Theme = 'light'; Key = 'LogWarnColor' }
        @{ Theme = 'light'; Key = 'LogErrorColor' }
        @{ Theme = 'dark'; Key = 'LogFgColor' }
        @{ Theme = 'dark'; Key = 'LogInfoColor' }
        @{ Theme = 'dark'; Key = 'LogWarnColor' }
        @{ Theme = 'dark'; Key = 'LogErrorColor' }
    ) {
        [Hashtable]$Colors = Get-ThemeColors -Light:($Theme -eq 'light')

        # WCAG AA for normal-size text
        Get-ContrastRatio $Colors[$Key] $Colors['LogBgColor'] | Should -BeGreaterOrEqual 4.5
    }

    It 'Should use only the system colours in high contrast, whatever the light setting' {
        [Hashtable]$Colors = Get-ThemeColors -Light -HighContrast

        [String[]]$SystemColors = @('WindowColor', 'WindowTextColor', 'HighlightColor', 'HighlightTextColor', 'ControlColor', 'GrayTextColor') |
            ForEach-Object { ConvertTo-HexColor ([Windows.SystemColors]::$_) }

        $Colors.Values | ForEach-Object { $_ | Should -BeIn $SystemColors }
        $Colors['FgColor'] | Should -BeExactly (ConvertTo-HexColor ([Windows.SystemColors]::WindowTextColor))
        $Colors['AccentTextColor'] | Should -BeExactly (ConvertTo-HexColor ([Windows.SystemColors]::HighlightTextColor))
    }
}

Describe 'ConvertTo-HexColor' {
    It 'Should format a colour as #RRGGBB' {
        ConvertTo-HexColor ([Windows.Media.Color]::FromRgb(0, 128, 255)) | Should -BeExactly '#0080FF'
    }
}
