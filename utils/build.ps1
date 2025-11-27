#Requires -PSEdition Desktop
#Requires -Version 3

param(
    [Switch]$Run
)

Set-Variable -Option Constant Version ([String](Get-Date -Format 'y.M.d'))
Set-Variable -Option Constant ProjectName ([String]'qiiwexc')

Set-Variable -Option Constant ConfigPath ([String]'.\config')
Set-Variable -Option Constant TemplatesPath ([String]'.\templates')
Set-Variable -Option Constant UtilsPath ([String]'.\utils')
Set-Variable -Option Constant SourcePath ([String]'.\src')
Set-Variable -Option Constant DistPath ([String]'.\d')
Set-Variable -Option Constant BuilderPath ([String]"$UtilsPath\build")
Set-Variable -Option Constant CommonPath ([String]"$UtilsPath\common")
Set-Variable -Option Constant UnattendedPath ([String]"$BuilderPath\unattended")

. "$CommonPath\logger.ps1"
. "$BuilderPath\Get-Config.ps1"
. "$BuilderPath\New-BatchScript.ps1"
. "$BuilderPath\New-HtmlFile.ps1"
. "$BuilderPath\New-PowerShellScript.ps1"
. "$BuilderPath\Set-Urls.ps1"
. "$BuilderPath\Write-VersionFile.ps1"
. "$UnattendedPath\New-UnattendedFile.ps1"

Set-Variable -Option Constant VersionFile ([String]"$DistPath\version")
Set-Variable -Option Constant Ps1File ([String]"$DistPath\$ProjectName.ps1")
Set-Variable -Option Constant BatchFile ([String]"$DistPath\$ProjectName.bat")
Set-Variable -Option Constant UnattendedFile ([String]"$DistPath\autounattend-{LOCALE}.xml")

Write-LogInfo 'Build task started'
Write-LogInfo "Version     = $Version"
Write-LogInfo "Source path = $SourcePath"
Write-LogInfo "Output file = $Ps1File"

Write-Progress -Activity 'Build' -PercentComplete 1

Set-Urls $ConfigPath $TemplatesPath
Write-Progress -Activity 'Build' -PercentComplete 10

Set-Variable -Option Constant Config (Get-Config $ConfigPath $Version)
Write-Progress -Activity 'Build' -PercentComplete 20

Write-VersionFile $Version $VersionFile
Write-Progress -Activity 'Build' -PercentComplete 30

New-HtmlFile $TemplatesPath $Config
Write-Progress -Activity 'Build' -PercentComplete 50

New-UnattendedFile $UnattendedPath $SourcePath $TemplatesPath $UnattendedFile
Write-Progress -Activity 'Build' -PercentComplete 60

New-PowerShellScript $SourcePath $Ps1File -Config $Config
Write-Progress -Activity 'Build' -PercentComplete 80

New-BatchScript $Ps1File $BatchFile
Write-Progress -Activity 'Build' -Complete

Write-LogInfo 'Build finished'

if ($Run) {
    Write-LogInfo "Running $BatchFile"
    Start-Process 'PowerShell' ".\$BatchFile Debug"
}
