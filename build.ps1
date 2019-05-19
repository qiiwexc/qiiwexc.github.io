Set-Variable SourcePath '.\src' -Option Constant
Set-Variable DistPath '.\d' -Option Constant
Set-Variable VersionFile "$DistPath\version" -Option Constant
Set-Variable TargetFile "$DistPath\qiiwexc.ps1" -Option Constant

Set-Variable INF 'INF' -Option Constant
Set-Variable WRN 'WRN' -Option Constant


Function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN')]$Level,
        [String][Parameter(Position = 1)]$Message = $(Write-Host "`n$($MyInvocation.MyCommand.Name): Log message missing" -NoNewline)
    )
    if (-not $Message) { Return }

    Set-Variable Text "[$((Get-Date).ToString())] $Message" -Option Constant
    Switch ($Level) { $WRN { Write-Warning $Text } $INF { Write-Host $Text } Default { Write-Host $Message } }
}


Function Start-Build {
    Param([Switch]$AndRun)

    Set-Variable Version (Get-Date -Format 'y.M.d') -Option Constant

    Add-Log $INF 'Build task started'
    Add-Log $INF "Source path = $SourcePath"
    Add-Log $INF "Target file = $TargetFile"
    Add-Log $INF "Version     = $Version"

    Remove-Item $TargetFile -Force -ErrorAction SilentlyContinue
    Remove-Item $VersionFile -Force -ErrorAction SilentlyContinue
    New-Item $DistPath -ItemType Directory -Force | Out-Null

    Add-Log $INF 'Writing version file'
    Add-Content $VersionFile "$Version`n" -NoNewline

    Add-Log $INF 'Building...'
    Add-Content $TargetFile "Set-Variable Version ([Version]'$Version') -Option Constant"

    ForEach ($File In Get-ChildItem $SourcePath -Recurse -File) {
        [String]$SectionName = $File.ToString().Replace('.ps1', '').Remove(0, 3)
        [String]$Spacer = '=-' * (30 - [Math]::Round(($SectionName.length + 1) / 4))

        Add-Content $TargetFile "`n`n#$Spacer# $SectionName #$Spacer#`n"
        Add-Content $TargetFile (Get-Content $File.FullName)
    }

    Add-Log $INF 'Finished'

    if ($AndRun) { Add-Log $INF "Running $TargetFile"; Start-Process 'PowerShell' ".\$TargetFile" }
}


if ($args[0] -eq '--and-run') { Start-Build -AndRun } else { Start-Build }
