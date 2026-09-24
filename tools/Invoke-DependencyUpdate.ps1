#Requires -Version 5

# Orchestrates the dependency update check for the nightly workflow: writes to GITHUB_OUTPUT whether a
# pull request is needed, and the description for it to build\dependency-update.md

$ErrorActionPreference = 'Stop'

Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent $PSScriptRoot))
Set-Variable -Option Constant ResourcesPath ([String]"$ProjectRoot\resources")
Set-Variable -Option Constant DescriptionFile ([String]"$ProjectRoot\build\dependency-update.md")

# Individual dependencies that cannot be checked are skipped with a warning — an error here
# means nothing could be checked at all, which must fail the workflow rather than look like "no updates"
try {
    & "$PSScriptRoot\build.ps1" -Update -CI
} catch {
    Write-Host "::error::Dependency update failed: $_"
    exit 1
}

[String]$Diff = git diff --name-only --ignore-cr-at-eol -- resources/dependencies.json

if (-not $Diff) {
    'has_updates=false' >> $env:GITHUB_OUTPUT
    return
}

. "$PSScriptRoot\common\types.ps1"
. "$PSScriptRoot\common\logger.ps1"
. "$PSScriptRoot\common\Write-TextFile.ps1"
. "$PSScriptRoot\build\Compare-Dependencies.ps1"
. "$PSScriptRoot\build\New-DependencyUpdateDescription.ps1"
. "$PSScriptRoot\build\updates\Format-ReleaseNotes.ps1"
. "$PSScriptRoot\build\updates\Get-ReleaseNotes.ps1"
. "$PSScriptRoot\build\updates\Invoke-GitAPI.ps1"

# git writes UTF-8, and a scraped version such as the Windows one is not ASCII: decoded with the
# console's code page it would differ from the file and show up as a change that never happened
[Console]::OutputEncoding = [Text.Encoding]::UTF8
[Dependency[]]$OldDeps = git show HEAD:resources/dependencies.json | ConvertFrom-Json
[Dependency[]]$NewDeps = Get-Content "$ResourcesPath\dependencies.json" -Raw -Encoding UTF8 | ConvertFrom-Json
[PSCustomObject]$UrlsTemplate = Get-Content "$ResourcesPath\urls.json" -Raw -Encoding UTF8 | ConvertFrom-Json

[PSCustomObject]$Result = Compare-Dependencies $OldDeps $NewDeps $UrlsTemplate

# A pull request is opened when the built artifacts change (a new download URL) or the CI tools change
[Bool]$HasUpdates = $Result.HasUrlChange -or $Result.HasToolChange
"has_updates=$($HasUpdates.ToString().ToLower())" >> $env:GITHUB_OUTPUT

if ($HasUpdates) {
    # build.ps1 -CI leaves the changelog links of every version it moved in this variable
    [String[]]$ChangelogUrls = @("$env:CHANGELOG_URLS" -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })

    [String]$Description = New-DependencyUpdateDescription $Result.Updates $ChangelogUrls $env:GITHUB_TOKEN
    Write-TextFile $DescriptionFile $Description -Normalize
}
