#pester:no-parallel - starts two WPF processes and writes to fixed paths under build\ui-snapshots

# Opt-in (tools\test.ps1 -Visual, or test-visual.bat): renders every tab in every theme from the committed
# source and from the working tree, on this machine, and expects the same pixels - so a change to how
# the window is put together is checked to look the same, rather than eyeballed
Describe 'UI snapshots' -Tag 'Visual' {
    BeforeAll {
        . "$PSScriptRoot\Compare-UiSnapshot.ps1"

        Add-Type -AssemblyName PresentationCore

        Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
        Set-Variable -Option Constant SnapshotsPath ([String]"$ProjectRoot\build\ui-snapshots")
        Set-Variable -Option Constant BasePath ([String]"$SnapshotsPath\base")
        Set-Variable -Option Constant CurrentPath ([String]"$SnapshotsPath\current")
        Set-Variable -Option Constant DiffPath ([String]"$SnapshotsPath\diff")

        function Export-Snapshot {
            param(
                [Parameter(Position = 0, Mandatory)][String]$SourcePath,
                [Parameter(Position = 1, Mandatory)][String]$OutputPath
            )

            [String[]]$Output = @(& powershell -NoProfile -ExecutionPolicy Bypass -STA -File "$PSScriptRoot\Export-UiSnapshot.ps1" -SourcePath $SourcePath -OutputPath $OutputPath 2>&1 | ForEach-Object { "$_" })
            if ($LASTEXITCODE -ne 0) {
                throw "Rendering '$SourcePath' failed:`n$($Output -join "`n")"
            }
        }

        if (Test-Path -LiteralPath $SnapshotsPath) {
            Remove-Item -LiteralPath $SnapshotsPath -Recurse -Force
        }
        $Null = New-Item -ItemType Directory $SnapshotsPath, $DiffPath

        # The source as last committed, as the base the working tree is compared with
        git -C $ProjectRoot archive --format=zip -o "$SnapshotsPath\base-src.zip" HEAD src
        if ($LASTEXITCODE -ne 0) {
            throw 'git archive failed'
        }
        Expand-Archive -LiteralPath "$SnapshotsPath\base-src.zip" -DestinationPath "$SnapshotsPath\base-src"

        Export-Snapshot "$SnapshotsPath\base-src\src" $BasePath
        Export-Snapshot "$ProjectRoot\src" $CurrentPath
    }

    It 'Should render the same tabs in the same themes as the committed source' {
        @(Get-ChildItem -LiteralPath $CurrentPath -Filter *.png).Name | Should -BeExactly @(Get-ChildItem -LiteralPath $BasePath -Filter *.png).Name
    }

    It 'Should render every tab pixel for pixel as the committed source does' {
        [String[]]$Differences = @(foreach ($Base in @(Get-ChildItem -LiteralPath $BasePath -Filter *.png)) {
                [String]$Current = "$CurrentPath\$($Base.Name)"
                if (Test-Path -LiteralPath $Current) {
                    [String]$Difference = Compare-UiSnapshot $Base.FullName $Current "$DiffPath\$($Base.Name)"
                    if ($Difference) {
                        "$($Base.BaseName): $Difference"
                    }
                }
            })

        $Differences | Should -BeNullOrEmpty
    }
}
