#Requires -Version 5

param(
    [Switch]$Autounattend,
    [Switch]$Bat,
    [Switch]$Dev,
    [Switch]$Full,
    [Switch]$Html,
    [Switch]$Ps1,
    [Switch]$Tests,
    [Switch]$Update
)

if ($Full) {
    $Autounattend = $True
    $Bat = $True
    $Html = $True
    $Ps1 = $True
    $Tests = $True
    $Update = $True
}

if ($Dev) {
    $Bat = $True
}

if ($Bat) {
    $Ps1 = $True
}

Set-Variable -Option Constant Version ([String](Get-Date -Format 'y.M.d'))
Set-Variable -Option Constant ProjectName ([String]'qiiwexc')

Set-Variable -Option Constant BuildPath ([String]'.\build')
Set-Variable -Option Constant ConfigPath ([String]'.\config')
Set-Variable -Option Constant DistPath ([String]'.\d')
Set-Variable -Option Constant SourcePath ([String]'.\src')
Set-Variable -Option Constant TemplatesPath ([String]'.\templates')
Set-Variable -Option Constant ToolsPath ([String]'.\tools')
Set-Variable -Option Constant VmPath ([String]'.\vm')
Set-Variable -Option Constant WipPath ([String]'.\wip')

Set-Variable -Option Constant BuilderPath ([String]"$ToolsPath\build")
Set-Variable -Option Constant CommonPath ([String]"$ToolsPath\common")

Set-Variable -Option Constant TestsFile ([String]"$ToolsPath\test.ps1")
Set-Variable -Option Constant VersionFile ([String]"$DistPath\version")
Set-Variable -Option Constant Ps1File ([String]"$BuildPath\$ProjectName.ps1")
Set-Variable -Option Constant BatchFile ([String]"$DistPath\$ProjectName.bat")

. "$CommonPath\logger.ps1"
. "$CommonPath\Write-File.ps1"
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
Write-LogInfo "Run tests                : $Tests"
Write-LogInfo "Check for updates        : $Update"
Write-LogInfo "Build HTML page          : $Html"
Write-LogInfo "Build autounattend files : $Autounattend"
Write-LogInfo "Build PowerShell script  : $Ps1"
Write-LogInfo "Build batch script       : $Bat"
Write-LogInfo "Run in dev mode          : $Dev"

Write-Progress -Activity 'Build' -PercentComplete 1

New-Item -Force -ItemType Directory $BuildPath | Out-Null
New-Item -Force -ItemType Directory $DistPath | Out-Null

if ($Tests) {
    . $TestsFile -Coverage
    Write-Progress -Activity 'Build' -PercentComplete 20
}

if ($Update) {
    Update-Dependencies $ConfigPath $BuilderPath $WipPath
    Write-Progress -Activity 'Build' -PercentComplete 30
}

if ($Html -or $Ps1) {
    Set-Urls $ConfigPath $TemplatesPath $BuildPath
    Write-Progress -Activity 'Build' -PercentComplete 40

    Set-Variable -Option Constant Config (Get-Config $BuildPath $Version)
    Write-Progress -Activity 'Build' -PercentComplete 50

    Write-VersionFile $Version $VersionFile
    Write-Progress -Activity 'Build' -PercentComplete 60
}

if ($Html) {
    New-HtmlFile $TemplatesPath $Config
    Write-Progress -Activity 'Build' -PercentComplete 70
}

if ($Autounattend) {
    New-UnattendedFile $Version $BuilderPath $SourcePath $TemplatesPath $BuildPath $DistPath $VmPath
    Write-Progress -Activity 'Build' -PercentComplete 80
}

if ($Ps1) {
    New-PowerShellScript $SourcePath $Ps1File -Config $Config
    Write-Progress -Activity 'Build' -PercentComplete 90
}

if ($Bat) {
    New-BatchScript $ProjectName $Ps1File $BatchFile $VmPath
}

Write-Progress -Activity 'Build' -Complete
Write-LogInfo 'Build finished'

if ($Dev) {
    Write-LogInfo "Running $BatchFile"
    Start-Process 'PowerShell' ".\$BatchFile Debug"
}
