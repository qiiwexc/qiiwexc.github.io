#Requires -Version 5

# Renders every tab of the app's window, as a given source tree builds it, to one PNG file per tab and
# theme, without showing the window. It runs the source as the bundle does, so it works whatever the
# layout code looks like. Run it in a fresh STA process, as the app's constants and types cannot be
# defined twice in one session:
#   powershell -NoProfile -ExecutionPolicy Bypass -STA -File tools\ui\Export-UiSnapshot.ps1 -SourcePath src -OutputPath <folder>

param(
    [Parameter(Mandatory)][String]$SourcePath,
    [Parameter(Mandatory)][String]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne [Threading.ApartmentState]::STA) {
    throw 'WPF needs an STA thread: run this script with powershell -STA'
}

. "$PSScriptRoot\..\build\Get-SourceFiles.ps1"

# What the parameter block, the version and the elevation provide in the bundle, which are not run here.
# Read by the source below: dev mode keeps the console window from being hidden
Set-Variable WorkingDirectory ([String]$OutputPath)
Set-Variable DevMode ([Switch]$True)
Set-Variable -Option Constant VERSION ([Version]'0.0')

Set-Variable -Option Constant SkippedFiles ([String[]]@('0 Parameters.ps1', '1 Version.ps1', '2 Start elevated.ps1'))
Set-Variable -Option Constant ShowWindow ([String]'[Void]$FORM.ShowDialog()')

foreach ($File in @(Get-SourceFiles $SourcePath)) {
    if ($File.Extension -ne '.ps1' -or ($File.Directory.Name -eq '0-init' -and $File.Name -in $SkippedFiles)) {
        continue
    }

    [String]$Code = [IO.File]::ReadAllText($File.FullName)

    # The entry point builds whatever is left of the window and shows it; showing it would block here
    if ($File.Directory.Name -eq '5-interface') {
        [Int]$Count = ([Regex]::Matches($Code, [Regex]::Escape($ShowWindow))).Count
        if ($Count -ne 1) {
            throw "Expected '$ShowWindow' once in '$($File.FullName)', found it $Count times"
        }
        $Code = $Code.Replace($ShowWindow, '')
    }

    . ([ScriptBlock]::Create($Code))
}

# The tabs move out of the window into a frame of their own, which gets the window's styles and, theme by
# theme, its colours: a window that is never shown has no layout to render
Set-Variable -Option Constant SnapshotFrame ([Windows.Controls.Border]::new())
foreach ($Key in @($FORM.Resources.Keys)) {
    $SnapshotFrame.Resources[$Key] = $FORM.Resources[$Key]
}
$SnapshotFrame.SetResourceReference([Windows.Controls.Border]::BackgroundProperty, 'BgColor')

([Windows.Controls.Panel]$TAB_CONTROL.Parent).Children.Remove($TAB_CONTROL)
$SnapshotFrame.Child = $TAB_CONTROL

# The width the tabs have in the window: its 1-pixel border and the tab control's margins taken off
Set-Variable -Option Constant SnapshotWidth ([Int]($FORM_MIN_WIDTH - 2 - 16))

Set-Variable -Option Constant SnapshotThemes ([Ordered]@{
        Light        = Get-ThemeColors -Light
        Dark         = Get-ThemeColors
        HighContrast = Get-ThemeColors -HighContrast
    })

Set-Variable -Option Constant SnapshotConverter ([Windows.Media.BrushConverter]::new())

$Null = New-Item -ItemType Directory -Force $OutputPath

foreach ($Theme in $SnapshotThemes.Keys) {
    foreach ($Entry in $SnapshotThemes[$Theme].GetEnumerator()) {
        $SnapshotFrame.Resources[$Entry.Key] = $SnapshotConverter.ConvertFromString($Entry.Value)
    }

    for ($Index = 0; $Index -lt $TAB_CONTROL.Items.Count; $Index++) {
        $TAB_CONTROL.SelectedIndex = $Index

        # Lets the tab control swap in the selected page before it is measured
        $SnapshotFrame.Dispatcher.Invoke([Action] {}, [Windows.Threading.DispatcherPriority]::Background)

        $SnapshotFrame.Measure([Windows.Size]::new($SnapshotWidth, [Double]::PositiveInfinity))
        $SnapshotFrame.Arrange([Windows.Rect]::new(0, 0, $SnapshotWidth, $SnapshotFrame.DesiredSize.Height))
        $SnapshotFrame.UpdateLayout()

        [Windows.Media.Imaging.RenderTargetBitmap]$Bitmap = [Windows.Media.Imaging.RenderTargetBitmap]::new($SnapshotWidth, [Int][Math]::Ceiling($SnapshotFrame.DesiredSize.Height), 96, 96, [Windows.Media.PixelFormats]::Pbgra32)
        $Bitmap.Render($SnapshotFrame)

        [Windows.Media.Imaging.PngBitmapEncoder]$Encoder = [Windows.Media.Imaging.PngBitmapEncoder]::new()
        $Encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($Bitmap))

        [String]$Header = $TAB_CONTROL.Items[$Index].Header
        [IO.FileStream]$Stream = [IO.File]::Create("$OutputPath\$Theme-$($Index + 1) $Header.png")
        try {
            $Encoder.Save($Stream)
        } finally {
            $Stream.Dispose()
        }
    }
}
