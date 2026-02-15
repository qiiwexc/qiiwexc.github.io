Set-Variable -Option Constant FONT_NAME ([String]'Segoe UI')
Set-Variable -Option Constant FONT_SIZE_NORMAL ([Int]12)
Set-Variable -Option Constant FONT_SIZE_BUTTON ([Int]14)
Set-Variable -Option Constant FONT_SIZE_HEADER ([Int]16)

Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)
Set-Variable -Option Constant FORM_MIN_WIDTH ([Int]725)
Set-Variable -Option Constant FORM_MIN_HEIGHT ([Int]765)

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class IconExtractor {
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern int ExtractIconEx(string lpszFile, int nIconIndex, IntPtr[] phiconLarge, IntPtr[] phiconSmall, int nIcons);
    [DllImport("user32.dll")]
    public static extern bool DestroyIcon(IntPtr hIcon);
}
'@

function Get-Shell32Icon {
    param([Int]$Index)
    $large = New-Object IntPtr[] 1
    $small = New-Object IntPtr[] 1
    [void][IconExtractor]::ExtractIconEx("$PATH_SYSTEM_32\shell32.dll", $Index, $large, $small, 1)
    if ($small[0] -ne [IntPtr]::Zero) { [void][IconExtractor]::DestroyIcon($small[0]) }
    Set-Variable -Option Constant Icon ([Drawing.Icon][Drawing.Icon]::FromHandle($large[0]).Clone())
    [void][IconExtractor]::DestroyIcon($large[0])
    return $Icon
}

Set-Variable -Option Constant ICON_DEFAULT ([Drawing.Icon](Get-Shell32Icon 314))
Set-Variable -Option Constant ICON_WORKING ([Drawing.Icon](Get-Shell32Icon 238))

# Mutable layout state — tracks the previous element and current container
# so component functions (New-Button, New-Card, etc.) can adjust spacing
Set-Variable -Scope Script PREVIOUS_LABEL_OR_CHECKBOX $Null
Set-Variable -Scope Script PREVIOUS_BUTTON $Null
Set-Variable -Scope Script CURRENT_GROUP $Null
Set-Variable -Scope Script CURRENT_TAB $Null
Set-Variable -Scope Script CENTERED_CHECKBOX_GROUP $Null
