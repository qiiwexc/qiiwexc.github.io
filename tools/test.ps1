#Requires -Version 5

param(
    [Switch]$Coverage,
    [Switch]$Wip
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Load Pester before the [PesterConfiguration] type is referenced
Import-Module Pester -MinimumVersion 5.0

Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent $PSScriptRoot))

Set-Variable -Option Constant Configuration ([PesterConfiguration](New-PesterConfiguration -Hashtable (. "$ProjectRoot/PesterSettings.ps1" -Coverage:$Coverage -Wip:$Wip)))
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
