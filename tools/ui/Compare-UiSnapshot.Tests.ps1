BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationCore

    # A solid grey image, optionally with one pixel painted red
    function New-TestImage {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Path,
            [Parameter(Position = 1, Mandatory)][Int]$Width,
            [Parameter(Position = 2, Mandatory)][Int]$Height,
            [Int[]]$RedPixel
        )

        [Byte[]]$Pixels = [Byte[]]::new($Width * $Height * 4)
        for ($Index = 0; $Index -lt $Pixels.Length; $Index++) {
            $Pixels[$Index] = if ($Index % 4 -eq 3) { 255 } else { 128 }
        }
        if ($RedPixel) {
            [Int]$Offset = ($RedPixel[1] * $Width + $RedPixel[0]) * 4
            $Pixels[$Offset] = 0
            $Pixels[$Offset + 1] = 0
            $Pixels[$Offset + 2] = 255
        }

        [Windows.Media.Imaging.PngBitmapEncoder]$Encoder = [Windows.Media.Imaging.PngBitmapEncoder]::new()
        $Encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create([Windows.Media.Imaging.BitmapSource]::Create($Width, $Height, 96, 96, [Windows.Media.PixelFormats]::Pbgra32, $Null, $Pixels, $Width * 4)))
        [IO.FileStream]$Stream = [IO.File]::Create($Path)
        try {
            $Encoder.Save($Stream)
        } finally {
            $Stream.Dispose()
        }
    }

    New-TestImage -Path "$TestDrive\base.png" -Width 20 -Height 10
    New-TestImage -Path "$TestDrive\same.png" -Width 20 -Height 10
    New-TestImage -Path "$TestDrive\changed.png" -Width 20 -Height 10 -RedPixel 3, 7
    New-TestImage -Path "$TestDrive\taller.png" -Width 20 -Height 11
}

Describe 'Compare-UiSnapshot' {
    It 'Should report nothing for identical images, and draw no diff' {
        Compare-UiSnapshot "$TestDrive\base.png" "$TestDrive\same.png" "$TestDrive\diff-same.png" | Should -BeExactly ''

        Test-Path -LiteralPath "$TestDrive\diff-same.png" | Should -BeFalse
    }

    It 'Should count the changed pixels and mark them in the diff image' {
        Compare-UiSnapshot "$TestDrive\base.png" "$TestDrive\changed.png" "$TestDrive\diff-changed.png" | Should -BeExactly "1 pixels changed, shown in '$TestDrive\diff-changed.png'"

        [PSCustomObject]$Diff = Read-UiSnapshot "$TestDrive\diff-changed.png"
        [Int]$Changed = (7 * 20 + 3) * 4
        $Diff.Pixels[$Changed + 2] | Should -Be 255
        $Diff.Pixels[$Changed] | Should -Be 0
        # Everything else is the expected image, faded: 128 + 128 / 2
        $Diff.Pixels[0] | Should -Be 192
    }

    It 'Should report a change of size without comparing pixels' {
        Compare-UiSnapshot "$TestDrive\base.png" "$TestDrive\taller.png" "$TestDrive\diff-taller.png" | Should -BeExactly 'size 20x10 became 20x11'

        Test-Path -LiteralPath "$TestDrive\diff-taller.png" | Should -BeFalse
    }
}
