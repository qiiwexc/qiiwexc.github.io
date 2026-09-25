BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\..\Common\New-Directory.ps1"
    . "$PSScriptRoot\..\..\..\Common\Remove-Directory.ps1"
    . "$PSScriptRoot\..\..\..\App lifecycle\Progressbar.ps1"

    Set-Variable -Option Constant PATH_APP_DIR ([String]"$TestDrive\app")

    # A release archive as GitHub builds it: everything inside one folder named after the tag
    function New-TestArchive {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Name,
            [Parameter(Position = 1, Mandatory)][String[]]$Files
        )

        Set-Variable -Option Constant SourcePath ([String]"$TestDrive\source-$Name")
        foreach ($File in $Files) {
            $Null = New-Item -ItemType File -Force "$SourcePath\$File" -Value $File
        }

        Set-Variable -Option Constant ArchivePath ([String]"$TestDrive\$Name.zip")
        Compress-Archive -Path "$SourcePath\*" -DestinationPath $ArchivePath
        return $ArchivePath
    }

    Set-Variable -Option Constant TestToolFiles ([String[]]@(
            'Win11Debloat-1.0\Win11Debloat.ps1',
            'Win11Debloat-1.0\Config\Apps.json',
            'Win11Debloat-1.0\Scripts\Main.ps1'
        ))
}

Describe 'Expand-WindowsDebloat' {
    BeforeAll {
        Mock Write-ActivityProgress {}
    }

    It 'Should unpack the release folder into the tool folder and return its script' {
        Set-Variable -Option Constant ZipPath ([String](New-TestArchive 'fresh' $TestToolFiles))
        Set-Variable -Option Constant ToolPath ([String]"$TestDrive\tool-fresh")

        Expand-WindowsDebloat $ZipPath $ToolPath | Should -BeExactly "$ToolPath\Win11Debloat.ps1"

        Get-Content -LiteralPath "$ToolPath\Win11Debloat.ps1" | Should -BeExactly 'Win11Debloat-1.0\Win11Debloat.ps1'
        Test-Path -LiteralPath "$ToolPath\Config\Apps.json" | Should -BeTrue
        Test-Path -LiteralPath "$ToolPath\Scripts\Main.ps1" | Should -BeTrue
        Test-Path -LiteralPath "$PATH_APP_DIR\Win11Debloat" | Should -BeFalse
    }

    It 'Should keep the backups and logs of earlier runs, and replace everything else' {
        Set-Variable -Option Constant ZipPath ([String](New-TestArchive 'update' $TestToolFiles))
        Set-Variable -Option Constant ToolPath ([String]"$TestDrive\tool-update")
        foreach ($File in @('Backups\backup.json', 'Logs\Win11Debloat.log', 'Config\LastUsedSettings.json', 'Scripts\Removed.ps1', 'stale.txt')) {
            $Null = New-Item -ItemType File -Force "$ToolPath\$File" -Value 'OLD'
        }

        Expand-WindowsDebloat $ZipPath $ToolPath

        Test-Path -LiteralPath "$ToolPath\Backups\backup.json" | Should -BeTrue
        Test-Path -LiteralPath "$ToolPath\Logs\Win11Debloat.log" | Should -BeTrue
        Test-Path -LiteralPath "$ToolPath\Config\LastUsedSettings.json" | Should -BeFalse
        Test-Path -LiteralPath "$ToolPath\Scripts\Removed.ps1" | Should -BeFalse
        Test-Path -LiteralPath "$ToolPath\stale.txt" | Should -BeFalse
        Test-Path -LiteralPath "$ToolPath\Scripts\Main.ps1" | Should -BeTrue
    }

    It 'Should not mix in what an interrupted extraction left behind' {
        Set-Variable -Option Constant ZipPath ([String](New-TestArchive 'leftover' $TestToolFiles))
        Set-Variable -Option Constant ToolPath ([String]"$TestDrive\tool-leftover")
        $Null = New-Item -ItemType File -Force "$PATH_APP_DIR\Win11Debloat\Win11Debloat-0.9\Win11Debloat.ps1" -Value 'OLD'

        Expand-WindowsDebloat $ZipPath $ToolPath

        Get-Content -LiteralPath "$ToolPath\Win11Debloat.ps1" | Should -BeExactly 'Win11Debloat-1.0\Win11Debloat.ps1'
    }

    It 'Should refuse an archive that is not a single folder' {
        Set-Variable -Option Constant ZipPath ([String](New-TestArchive 'two-folders' @('One\Win11Debloat.ps1', 'Two\Win11Debloat.ps1')))

        { Expand-WindowsDebloat $ZipPath "$TestDrive\tool-two-folders" } | Should -Throw '*expected a single folder'

        Test-Path -LiteralPath "$TestDrive\tool-two-folders\Win11Debloat.ps1" | Should -BeFalse
    }

    It 'Should refuse an archive without the tool script' {
        Set-Variable -Option Constant ZipPath ([String](New-TestArchive 'no-script' @('Win11Debloat-1.0\README.md')))

        { Expand-WindowsDebloat $ZipPath "$TestDrive\tool-no-script" } | Should -Throw 'Win11Debloat.ps1 not found*'
    }
}
