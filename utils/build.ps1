#Requires -PSEdition Desktop
#Requires -Version 3

param(
    [Switch]$Autounattend,
    [Switch]$Bat,
    [Switch]$Dev,
    [Switch]$Full,
    [Switch]$Html,
    [Switch]$Ps1,
    [Switch]$Update
)

if ($Full) {
    $Autounattend = $true
    $Bat = $true
    $Html = $true
    $Ps1 = $true
    $Update = $true
}

if ($Dev) {
    $Bat = $true
}

if ($Bat) {
    $Ps1 = $true
}

Set-Variable -Option Constant Version ([String](Get-Date -Format 'y.M.d'))
Set-Variable -Option Constant ProjectName ([String]'qiiwexc')

Set-Variable -Option Constant ConfigPath ([String]'.\config')
Set-Variable -Option Constant DistPath ([String]'.\d')
Set-Variable -Option Constant SourcePath ([String]'.\src')
Set-Variable -Option Constant TemplatesPath ([String]'.\templates')
Set-Variable -Option Constant UtilsPath ([String]'.\utils')
Set-Variable -Option Constant WipPath ([String]'.\wip')

Set-Variable -Option Constant BuilderPath ([String]"$UtilsPath\build")
Set-Variable -Option Constant CommonPath ([String]"$UtilsPath\common")

Set-Variable -Option Constant VersionFile ([String]"$DistPath\version")
Set-Variable -Option Constant Ps1File ([String]"$DistPath\$ProjectName.ps1")
Set-Variable -Option Constant BatchFile ([String]"$DistPath\$ProjectName.bat")
Set-Variable -Option Constant UnattendedFile ([String]"$DistPath\autounattend-{LOCALE}.xml")

. "$CommonPath\logger.ps1"
. "$BuilderPath\Get-Config.ps1"
. "$BuilderPath\New-BatchScript.ps1"
. "$BuilderPath\New-HtmlFile.ps1"
. "$BuilderPath\New-PowerShellScript.ps1"
. "$BuilderPath\New-UnattendedFile.ps1"
. "$BuilderPath\Set-Urls.ps1"
. "$BuilderPath\Update-Dependencies.ps1"
. "$BuilderPath\Write-VersionFile.ps1"

Write-LogInfo 'Build task started'
Write-LogInfo "Version                  : $Version"
Write-LogInfo "Full build               : $Full"
Write-LogInfo "Check for updates        : $Update"
Write-LogInfo "Build HTML page          : $Html"
Write-LogInfo "Build autounattend files : $Autounattend"
Write-LogInfo "Build PowerShell script  : $Ps1"
Write-LogInfo "Build batch script       : $Bat"
Write-LogInfo "Run in dev mode          : $Dev"

Write-Progress -Activity 'Build' -PercentComplete 1

if ($Update) {
    Update-Dependencies $ConfigPath $BuilderPath $WipPath
    Write-Progress -Activity 'Build' -PercentComplete 30
}

if ($Html -or $Ps1) {
    Set-Urls $ConfigPath $TemplatesPath
    Write-Progress -Activity 'Build' -PercentComplete 40

    Set-Variable -Option Constant Config (Get-Config $ConfigPath $Version)
    Write-Progress -Activity 'Build' -PercentComplete 50

    Write-VersionFile $Version $VersionFile
    Write-Progress -Activity 'Build' -PercentComplete 60
}

if ($Html) {
    New-HtmlFile $TemplatesPath $Config
    Write-Progress -Activity 'Build' -PercentComplete 70
}

if ($Autounattend) {
    New-UnattendedFile $Version $ConfigPath $BuilderPath $SourcePath $TemplatesPath $UnattendedFile $Full
    Write-Progress -Activity 'Build' -PercentComplete 80
}

if ($Ps1) {
    New-PowerShellScript $SourcePath $Ps1File -Config $Config
    Write-Progress -Activity 'Build' -PercentComplete 90
}

if ($Bat) {
    New-BatchScript $Ps1File $BatchFile
}

Write-Progress -Activity 'Build' -Complete
Write-LogInfo 'Build finished'

if ($Dev) {
    Write-LogInfo "Running $BatchFile"
    Start-Process 'PowerShell' ".\$BatchFile Debug"
}
