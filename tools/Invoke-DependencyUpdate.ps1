#Requires -Version 5

# Orchestrates dependency update check and writes results to GITHUB_OUTPUT.
# Called by the nightly dependency update workflow.

$ErrorActionPreference = 'Stop'

Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent $PSScriptRoot))
Set-Variable -Option Constant ResourcesPath ([String]"$ProjectRoot\resources")

try {
    & "$PSScriptRoot\build.ps1" -Update -CI
} catch {
    Write-Host "::warning::Build script error: $_"
}

[String]$Diff = git diff --name-only --ignore-cr-at-eol -- resources/dependencies.json

if (-not $Diff) {
    'has_updates=false' >> $env:GITHUB_OUTPUT
    return
}

. "$PSScriptRoot\common\types.ps1"
. "$PSScriptRoot\build\Compare-Dependencies.ps1"

[Dependency[]]$OldDeps = git show HEAD:resources/dependencies.json | ConvertFrom-Json
[Dependency[]]$NewDeps = Get-Content "$ResourcesPath\dependencies.json" -Raw | ConvertFrom-Json
[PSCustomObject]$UrlsTemplate = Get-Content "$ResourcesPath\urls.json" -Raw | ConvertFrom-Json

[PSCustomObject]$Result = Compare-Dependencies $OldDeps $NewDeps $UrlsTemplate

[String]$HasUpdates = $Result.HasUrlChange.ToString().ToLower()
"has_updates=$HasUpdates" >> $env:GITHUB_OUTPUT

if ($env:CHANGELOG_URLS) {
    'changelog_urls<<EOF' >> $env:GITHUB_OUTPUT
    $env:CHANGELOG_URLS >> $env:GITHUB_OUTPUT
    'EOF' >> $env:GITHUB_OUTPUT
}
