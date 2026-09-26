function Read-UiSnapshot {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    [IO.FileStream]$Stream = [IO.File]::OpenRead($Path)
    try {
        Set-Variable -Option Constant Decoder ([Windows.Media.Imaging.PngBitmapDecoder]::new($Stream, [Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat, [Windows.Media.Imaging.BitmapCacheOption]::OnLoad))
        Set-Variable -Option Constant Bitmap ([Windows.Media.Imaging.FormatConvertedBitmap]::new($Decoder.Frames[0], [Windows.Media.PixelFormats]::Pbgra32, $Null, 0))
        Set-Variable -Option Constant Stride ([Int]($Bitmap.PixelWidth * 4))
        Set-Variable -Option Constant Pixels ([Byte[]]::new($Stride * $Bitmap.PixelHeight))
        $Bitmap.CopyPixels($Pixels, $Stride, 0)

        return [PSCustomObject]@{
            Width  = [Int]$Bitmap.PixelWidth
            Height = [Int]$Bitmap.PixelHeight
            Pixels = $Pixels
        }
    } finally {
        $Stream.Dispose()
    }
}


function Compare-UiSnapshot {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ExpectedPath,
        [Parameter(Position = 1, Mandatory)][String]$ActualPath,
        [Parameter(Position = 2, Mandatory)][String]$DiffPath
    )

    Set-Variable -Option Constant Expected ([PSCustomObject](Read-UiSnapshot $ExpectedPath))
    Set-Variable -Option Constant Actual ([PSCustomObject](Read-UiSnapshot $ActualPath))

    if ($Expected.Width -ne $Actual.Width -or $Expected.Height -ne $Actual.Height) {
        return "size $($Expected.Width)x$($Expected.Height) became $($Actual.Width)x$($Actual.Height)"
    }

    if ([Linq.Enumerable]::SequenceEqual($Expected.Pixels, $Actual.Pixels)) {
        return ''
    }

    # The changed pixels in red over a faded copy of the expected image; only the rows that differ are
    # compared pixel by pixel, which keeps a small change quick to draw
    Set-Variable -Option Constant Stride ([Int]($Expected.Width * 4))
    Set-Variable -Option Constant Diff ([Byte[]]::new($Expected.Pixels.Length))
    for ($Index = 0; $Index -lt $Diff.Length; $Index += 4) {
        $Diff[$Index] = [Byte](128 + ($Expected.Pixels[$Index] -shr 1))
        $Diff[$Index + 1] = [Byte](128 + ($Expected.Pixels[$Index + 1] -shr 1))
        $Diff[$Index + 2] = [Byte](128 + ($Expected.Pixels[$Index + 2] -shr 1))
        $Diff[$Index + 3] = 255
    }

    [Int]$ChangedPixels = 0
    [Byte[]]$ExpectedRow = [Byte[]]::new($Stride)
    [Byte[]]$ActualRow = [Byte[]]::new($Stride)
    for ($Row = 0; $Row -lt $Expected.Height; $Row++) {
        [Array]::Copy($Expected.Pixels, $Row * $Stride, $ExpectedRow, 0, $Stride)
        [Array]::Copy($Actual.Pixels, $Row * $Stride, $ActualRow, 0, $Stride)
        if ([Linq.Enumerable]::SequenceEqual($ExpectedRow, $ActualRow)) {
            continue
        }

        for ($Column = 0; $Column -lt $Stride; $Column += 4) {
            if ([BitConverter]::ToInt32($ExpectedRow, $Column) -ne [BitConverter]::ToInt32($ActualRow, $Column)) {
                [Int]$Offset = $Row * $Stride + $Column
                $Diff[$Offset] = 0
                $Diff[$Offset + 1] = 0
                $Diff[$Offset + 2] = 255
                $ChangedPixels++
            }
        }
    }

    Set-Variable -Option Constant DiffBitmap ([Windows.Media.Imaging.BitmapSource]::Create($Expected.Width, $Expected.Height, 96, 96, [Windows.Media.PixelFormats]::Pbgra32, $Null, $Diff, $Stride))
    Set-Variable -Option Constant Encoder ([Windows.Media.Imaging.PngBitmapEncoder]::new())
    $Encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($DiffBitmap))
    [IO.FileStream]$Stream = [IO.File]::Create($DiffPath)
    try {
        $Encoder.Save($Stream)
    } finally {
        $Stream.Dispose()
    }

    return "$ChangedPixels pixels changed, shown in '$DiffPath'"
}
