Set-Variable -Option Constant FONT_NAME ([String]'Segoe UI')
Set-Variable -Option Constant FONT_SIZE_NORMAL ([Int]12)
Set-Variable -Option Constant FONT_SIZE_BUTTON ([Int]14)
Set-Variable -Option Constant FONT_SIZE_HEADER ([Int]16)

Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)
Set-Variable -Option Constant FORM_MIN_WIDTH ([Int]725)

function Get-DllIcon {
    param(
        [Parameter(Position = 0, Mandatory)][Int]$ResourceId
    )

    # By resource ID, which ExtractIconEx takes as a negative index: an icon keeps its ID when Windows adds others,
    # while its position among them shifts from one version to the next
    $large = New-Object IntPtr[] 1
    $small = New-Object IntPtr[] 1
    [void][Qiiwexc.NativeMethods]::ExtractIconEx("$PATH_SYSTEM_32\imageres.dll", -$ResourceId, $large, $small, 1)
    if ($small[0] -ne [IntPtr]::Zero) { [void][Qiiwexc.NativeMethods]::DestroyIcon($small[0]) }

    # An icon missing from this version of Windows must not stop the window from opening
    if ($large[0] -eq [IntPtr]::Zero) {
        return [Drawing.Icon][Drawing.SystemIcons]::Application.Clone()
    }

    Set-Variable -Option Constant TempIcon ([Drawing.Icon][Drawing.Icon]::FromHandle($large[0]))
    Set-Variable -Option Constant Icon ([Drawing.Icon]$TempIcon.Clone())
    $TempIcon.Dispose()
    [void][Qiiwexc.NativeMethods]::DestroyIcon($large[0])
    return $Icon
}

# A cube, and two circling arrows while an operation runs
Set-Variable -Option Constant ICON_DEFAULT ([Drawing.Icon](Get-DllIcon 198))
Set-Variable -Option Constant ICON_WORKING ([Drawing.Icon](Get-DllIcon 1401))
