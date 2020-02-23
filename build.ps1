Set-Variable -Option Constant Version     (Get-Date -Format 'y.M.d')

Set-Variable -Option Constant SourcePath  '.\src'
Set-Variable -Option Constant DistPath    '.\d'
Set-Variable -Option Constant VersionFile "$DistPath\version"
Set-Variable -Option Constant TargetFile  "$DistPath\qiiwexc.ps1"
Set-Variable -Option Constant WebPageFile ".\index.html"

Set-Variable -Option Constant HtmlTitle   "<title>qiiwexc $Version</title>"
Set-Variable -Option Constant HtmlHeader  "<h2><a href=`"d/qiiwexc.ps1`">qiiwexc $Version</a></h2>"

Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'


Function Add-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN')]$Level,
        [String][Parameter(Position = 1)]$Message = (Write-Host -NoNewline "`n$($MyInvocation.MyCommand.Name): Log message missing")
    )
    if (-not $Message) { Return }

    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"
    Switch ($Level) { $WRN { Write-Warning $Text } $INF { Write-Host $Text } Default { Write-Host $Message } }
}


Function Start-Build {
    Param([Switch]$AndRun)

    Add-Log $INF 'Build task started'
    Add-Log $INF "Source path = $SourcePath"
    Add-Log $INF "Target file = $TargetFile"
    Add-Log $INF "Version     = $Version"

    Remove-Item -Force -ErrorAction SilentlyContinue $TargetFile
    Remove-Item -Force -ErrorAction SilentlyContinue $VersionFile
    New-Item -ItemType Directory -Force $DistPath | Out-Null

    Add-Log $INF 'Writing version file'
    Set-Content $VersionFile "$Version`n" -NoNewline

    Add-Log $INF 'Updating version on the web page'
    (Get-Content $WebPageFile) | ForEach-Object { $_ -Replace "<title>.+", $HtmlTitle -Replace "<h2>.+", $HtmlHeader } | Set-Content $WebPageFile

    Add-Log $INF 'Building...'
    Add-Content $TargetFile "Set-Variable -Option Constant Version ([Version]'$Version')"

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
