#Requires -Version 5

param(
    [Switch]$Coverage,
    [Switch]$Wip,
    [Switch]$Visual
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent $PSScriptRoot))

# Load the Pester version pinned in dependencies.json — the one CI installs — rather than whichever
# is newest locally, and before the [PesterConfiguration] type is referenced
Set-Variable -Option Constant PesterVersion ([String]((Get-Content "$ProjectRoot\resources\dependencies.json" -Raw | ConvertFrom-Json) | Where-Object { $_.name -eq 'Pester' }).version)
try {
    Import-Module Pester -RequiredVersion $PesterVersion
} catch {
    throw "Pester $PesterVersion is not installed, run install-dependencies.bat: $_"
}

Set-Variable -Option Constant Configuration ([PesterConfiguration](New-PesterConfiguration -Hashtable (. "$ProjectRoot/PesterSettings.ps1" -Coverage:$Coverage -Wip:$Wip -Visual:$Visual)))
$Configuration.Run.PassThru = $True

Set-Variable -Option Constant Result ([PSObject](Invoke-Pester -Configuration $Configuration))

# Run.Exit already terminates with a non-zero exit code on test failures, so this
# is only reached on a green run — enforce the coverage target as well
if ($Coverage -and $Result -and $Result.CodeCoverage.CoveragePercent -lt $Result.CodeCoverage.CoveragePercentTarget) {
    Write-Host ('Code coverage {0:N2}% is below the target of {1:N2}%' -f $Result.CodeCoverage.CoveragePercent, $Result.CodeCoverage.CoveragePercentTarget)
    exit 1
}

# Make the success exit code explicit so callers checking $LASTEXITCODE never see a stale value
exit 0
