#Requires -Version 5

param(
    [Switch]$Dev,
    [Switch]$Full,
    [Switch]$CI,
    [Switch]$Run,
    [Switch]$Test,
    [Switch]$Update,
    [Switch]$Html,
    [Switch]$Autounattend,
    [Switch]$Ps1,
    [Switch]$Lint,
    [Switch]$Bat
)

if ($Full) {
    $Test = $True
    $Update = $True
}

if ($Full -or $CI) {
    $Autounattend = $True
    $Html = $True
    $Ps1 = $True
    $Lint = $True
    $Bat = $True
}

if ($Dev) {
    $Bat = $True
    $Run = $True
}

if ($Bat) {
    $Ps1 = $True
}

if (-not $Ps1) {
    $Lint = $False
}

$ErrorActionPreference = 'Stop'

Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent $PSScriptRoot))

Set-Variable -Option Constant ProjectName ([String]'qiiwexc')

Set-Variable -Option Constant BuildPath ([String]"$ProjectRoot\build")
Set-Variable -Option Constant DistPath ([String]"$ProjectRoot\d")
Set-Variable -Option Constant SourcePath ([String]"$ProjectRoot\src")
Set-Variable -Option Constant ResourcesPath ([String]"$ProjectRoot\resources")
Set-Variable -Option Constant TemplatesPath ([String]"$ProjectRoot\templates")
Set-Variable -Option Constant ToolsPath ([String]"$ProjectRoot\tools")
Set-Variable -Option Constant VmPath ([String]"$ProjectRoot\vm")
Set-Variable -Option Constant WipPath ([String]"$ProjectRoot\wip")

Set-Variable -Option Constant BuilderPath ([String]"$ToolsPath\build")
Set-Variable -Option Constant CommonPath ([String]"$ToolsPath\common")

Set-Variable -Option Constant TestsFile ([String]"$ToolsPath\test.ps1")
Set-Variable -Option Constant Ps1File ([String]"$BuildPath\$ProjectName.ps1")
Set-Variable -Option Constant BatchFile ([String]"$BuildPath\$ProjectName.bat")

if ($CI -and $Env:GITHUB_REF_NAME) {
    Set-Variable -Option Constant Version ([Version]$Env:GITHUB_REF_NAME)
} else {
    Set-Variable -Option Constant Version ([Version](Get-Date -Format 'y.M.d'))
}

. "$CommonPath\types.ps1"
. "$CommonPath\logger.ps1"
. "$CommonPath\Progressbar.ps1"
. "$CommonPath\Read-JsonFile.ps1"
. "$CommonPath\Read-TextFile.ps1"
. "$CommonPath\Write-JsonFile.ps1"
. "$CommonPath\Write-TextFile.ps1"

Write-LogInfo 'Build task started'
Write-LogInfo "Version                  : $Version"
Write-LogInfo "Full build               : $Full"
Write-LogInfo "CI build                 : $CI"
Write-LogInfo "Run tests                : $Test"
Write-LogInfo "Run linter               : $Lint"
Write-LogInfo "Check for updates        : $Update"
Write-LogInfo "Build HTML page          : $Html"
Write-LogInfo "Build autounattend files : $Autounattend"
Write-LogInfo "Build PowerShell script  : $Ps1"
Write-LogInfo "Build batch script       : $Bat"
Write-LogInfo "Run in dev mode          : $Run"

New-Activity 'Building'

$Null = New-Item -Force -ItemType Directory $BuildPath
$Null = New-Item -Force -ItemType Directory $DistPath

if ($Test) {
    Write-ActivityProgress 10 'Running unit tests...'
    Invoke-Pester -Configuration (. '.\PesterSettings.ps1' -Coverage)
    Out-Success
}

if ($Update) {
    Write-ActivityProgress 20
    . "$BuilderPath\Update-Dependencies.ps1"
    Update-Dependencies $ResourcesPath $BuilderPath $WipPath
}

if ($Html -or $Ps1) {
    Write-ActivityProgress 30
    . "$BuilderPath\Set-Urls.ps1"
    Set-Urls $ResourcesPath $BuildPath

    Write-ActivityProgress 40
    . "$BuilderPath\Get-Config.ps1"
    Set-Variable -Option Constant Config (Get-Config $BuildPath $Version)
}

if ($Html) {
    Write-ActivityProgress 50
    . "$BuilderPath\New-HtmlFile.ps1"
    New-HtmlFile $TemplatesPath $BuildPath $Config
}

if ($Autounattend) {
    Write-ActivityProgress 60
    . "$BuilderPath\New-UnattendedFile.ps1"
    New-UnattendedFile $Version $BuilderPath $SourcePath $ResourcesPath $TemplatesPath $BuildPath $VmPath -CI:$CI
}

if ($Ps1) {
    Write-ActivityProgress 70
    . "$BuilderPath\New-PowerShellScript.ps1"
    New-PowerShellScript $SourcePath $Ps1File -Config $Config
}

if ($Lint) {
    Write-ActivityProgress 80 'Running linter...'

    Set-Variable -Option Constant MaxRetries ([int]3)

    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Invoke-ScriptAnalyzer -Path $Ps1File -Settings .\PSScriptAnalyzerSettings.psd1 -ErrorAction Stop
            break
        } catch {
            if ($i -eq $MaxRetries) {
                throw
            }
            Write-LogInfo "Linter failed (attempt $i/$MaxRetries), retrying..."
            Start-Sleep -Seconds 1
        }
    }
    Out-Success
}

if ($Bat) {
    Write-ActivityProgress 90
    . "$BuilderPath\New-BatchScript.ps1"
    New-BatchScript $ProjectName $Ps1File $BatchFile $VmPath
}

Write-ActivityCompleted
Write-LogInfo 'Build finished'

if ($Run) {
    Write-LogInfo "Running $BatchFile"
    Start-Process 'PowerShell' "$BatchFile Debug"
}
