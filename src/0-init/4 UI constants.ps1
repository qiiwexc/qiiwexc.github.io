Set-Variable -Option Constant FONT_NAME ([String]'Segoe UI')
Set-Variable -Option Constant FONT_SIZE_NORMAL ([Int]12)
Set-Variable -Option Constant FONT_SIZE_BUTTON ([Int]14)
Set-Variable -Option Constant FONT_SIZE_HEADER ([Int]16)

Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)
Set-Variable -Option Constant FORM_MIN_WIDTH ([Int]725)

function Get-DllIcon {
    param([Int]$Index)
    $large = New-Object IntPtr[] 1
    $small = New-Object IntPtr[] 1
    [void][Qiiwexc.NativeMethods]::ExtractIconEx("$PATH_SYSTEM_32\imageres.dll", $Index, $large, $small, 1)
    if ($small[0] -ne [IntPtr]::Zero) { [void][Qiiwexc.NativeMethods]::DestroyIcon($small[0]) }
    Set-Variable -Option Constant TempIcon ([Drawing.Icon][Drawing.Icon]::FromHandle($large[0]))
    Set-Variable -Option Constant Icon ([Drawing.Icon]$TempIcon.Clone())
    $TempIcon.Dispose()
    [void][Qiiwexc.NativeMethods]::DestroyIcon($large[0])
    return $Icon
}

Set-Variable -Option Constant ICON_DEFAULT ([Drawing.Icon](Get-DllIcon 187))

if ($OS_VERSION -eq 10) {
    Set-Variable -Option Constant ICON_WORKING ([Drawing.Icon](Get-DllIcon 228))
} else {
    Set-Variable -Option Constant ICON_WORKING ([Drawing.Icon](Get-DllIcon 229))
}
