#Requires -PSEdition Desktop
#Requires -Version 3

param(
    [Switch]$Run
)

. '.\utils\logger.ps1'
. '.\utils\read-config.ps1'
. '.\utils\write-version-file.ps1'
. '.\utils\build-html-file.ps1'
. '.\utils\build-powershell-script.ps1'
. '.\utils\build-batch-script.ps1'

Set-Variable -Option Constant Version (Get-Date -Format 'y.M.d')
Set-Variable -Option Constant ProjectName 'qiiwexc'

Set-Variable -Option Constant AssetsPath '.\assets'
Set-Variable -Option Constant SourcePath '.\src'
Set-Variable -Option Constant DistPath '.\d'

Set-Variable -Option Constant VersionFile "$DistPath\version"
Set-Variable -Option Constant Ps1File "$DistPath\$ProjectName.ps1"
Set-Variable -Option Constant BatchFile "$DistPath\$ProjectName.bat"

Write-LogInfo 'Build task started'
Write-LogInfo "Version     = $Version"
Write-LogInfo "Source path = $SourcePath"
Write-LogInfo "Output file = $Ps1File"

Write-Progress -Activity 'Build' -PercentComplete 1

Set-Variable -Option Constant Config (Get-Config $AssetsPath $Version)
Write-Progress -Activity 'Build' -PercentComplete 10

Write-VersionFile $Version $VersionFile
Write-Progress -Activity 'Build' -PercentComplete 30

New-HtmlFile $AssetsPath $Config
Write-Progress -Activity 'Build' -PercentComplete 60

New-PowerShellScript $SourcePath $Ps1File -Config:$Config
Write-Progress -Activity 'Build' -PercentComplete 80

New-BatchScript $Ps1File $BatchFile
Write-Progress -Activity 'Build' -Complete

Write-LogInfo 'Build finished'

if ($Run) {
    Write-LogInfo "Running $BatchFile"
    Start-Process 'PowerShell' ".\$BatchFile Debug"
}
