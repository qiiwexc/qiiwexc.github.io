# Runs PSScriptAnalyzer on each path, one rule per call, and returns every finding. The analyzer runs a call's rules in
# parallel, and in Windows PowerShell 5.1 the rules that look commands up in the engine (PSAvoidUsingCmdletAliases and
# PSUseCorrectCasing among them) race each other: the call then fails with an error of the analyzer's own, such as
# "The term 'Get-Command' is not recognized", instead of reporting findings. The failed lookup stays cached for the
# rest of the process, so retrying in the same process fails the same way. One rule per call leaves nothing to race,
# at the cost of reading every file once per rule; once a release of the analyzer serialises its command lookups, one
# call per path will do again
function Invoke-Linter {
    param(
        [Parameter(Position = 0, Mandatory)][String[]]$Path,
        [Parameter(Position = 1, Mandatory)][String]$SettingsPath
    )

    Set-Variable -Option Constant Settings ([Hashtable](Import-PowerShellDataFile $SettingsPath))
    Set-Variable -Option Constant ExcludedRules ([String[]]@($Settings['ExcludeRules'] | Where-Object { $_ }))
    Set-Variable -Option Constant ConfiguredRules ([String[]]@($Settings['Rules'] | Where-Object { $_ } | ForEach-Object { $_.Keys }))
    Set-Variable -Option Constant AllRules ([String[]]@(Get-ScriptAnalyzerRule | ForEach-Object { $_.RuleName }))

    # The analyzer ignores a rule name it does not know, so a misspelt one would leave its rule silently unchecked
    Set-Variable -Option Constant UnknownRules ([String[]]@($ExcludedRules + $ConfiguredRules | Where-Object { $_ -notin $AllRules }))
    if ($UnknownRules.Count -gt 0) {
        throw "The linter settings name rules the analyzer does not have: $($UnknownRules -join ', ')"
    }

    Set-Variable -Option Constant RuleNames ([String[]]@($AllRules | Where-Object { $_ -notin $ExcludedRules }))

    [Collections.Generic.List[PSObject]]$Findings = @()
    foreach ($Target in $Path) {
        Write-LogInfo "Linting $Target with $($RuleNames.Count) rules, one at a time"

        foreach ($RuleName in $RuleNames) {
            $Findings.AddRange([PSObject[]]@(Invoke-ScriptAnalyzer -Path $Target -Recurse -Settings $SettingsPath -IncludeRule $RuleName -ErrorAction Stop))
        }
    }

    return $Findings
}
