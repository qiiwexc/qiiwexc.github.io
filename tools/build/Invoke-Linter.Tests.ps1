BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\common\logger.ps1"

    # Stand-ins for the analyzer's commands, which a test run does not load, so that they can be mocked on any host
    function Get-ScriptAnalyzerRule {}
    function Invoke-ScriptAnalyzer {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
        [CmdletBinding()]
        param(
            [String]$Path,
            [Switch]$Recurse,
            [String]$Settings,
            [String[]]$IncludeRule
        )
    }

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')
    Set-Variable -Option Constant TestSettingsPath ([String]'TEST_SETTINGS_PATH')
    Set-Variable -Option Constant TestPaths ([String[]]@('TEST_PATH_1', 'TEST_PATH_2'))
}

Describe 'Invoke-Linter' {
    BeforeAll {
        Mock Write-LogInfo {}
        Mock Import-PowerShellDataFile { return @{ ExcludeRules = @('PSExcludedRule') } }
        Mock Get-ScriptAnalyzerRule {
            return @(
                [PSCustomObject]@{ RuleName = 'PSFirstRule' }
                [PSCustomObject]@{ RuleName = 'PSExcludedRule' }
                [PSCustomObject]@{ RuleName = 'PSSecondRule' }
            )
        }
        Mock Invoke-ScriptAnalyzer { return [PSCustomObject]@{ ScriptName = $Path; RuleName = $IncludeRule[0] } }
    }

    It 'Should run the analyzer on every path one rule at a time, so that no two rules race' {
        Invoke-Linter $TestPaths $TestSettingsPath

        Should -Invoke Import-PowerShellDataFile -Exactly 1 -ParameterFilter { $Path -eq $TestSettingsPath }
        Should -Invoke Invoke-ScriptAnalyzer -Exactly 4
        foreach ($TestPath in $TestPaths) {
            foreach ($RuleName in @('PSFirstRule', 'PSSecondRule')) {
                Should -Invoke Invoke-ScriptAnalyzer -Exactly 1 -ParameterFilter {
                    $Path -eq $TestPath -and
                    $Recurse -and
                    $Settings -eq $TestSettingsPath -and
                    @($IncludeRule).Count -eq 1 -and
                    $IncludeRule[0] -eq $RuleName
                }
            }
        }
    }

    It 'Should leave out the rules the settings exclude' {
        Invoke-Linter $TestPaths $TestSettingsPath

        Should -Invoke Invoke-ScriptAnalyzer -Exactly 0 -ParameterFilter { $IncludeRule -contains 'PSExcludedRule' }
    }

    It 'Should run every rule when the settings exclude none' {
        Mock Import-PowerShellDataFile { return @{} }

        Invoke-Linter $TestPaths $TestSettingsPath

        Should -Invoke Invoke-ScriptAnalyzer -Exactly 6
    }

    It 'Should fail on a rule the settings <Where> that the analyzer does not have, rather than leave it unchecked' -ForEach @(
        @{ Where = 'exclude'; Settings = @{ ExcludeRules = @('PSExcludedRule', 'PSMisspeltRule') } }
        @{ Where = 'configure'; Settings = @{ Rules = @{ PSFirstRule = @{ Enable = $True }; PSMisspeltRule = @{ Enable = $True } } } }
    ) {
        Mock Import-PowerShellDataFile { return $Settings }

        { Invoke-Linter $TestPaths $TestSettingsPath } | Should -Throw 'The linter settings name rules the analyzer does not have: PSMisspeltRule'

        Should -Invoke Invoke-ScriptAnalyzer -Exactly 0
    }

    It 'Should return the findings of every rule on every path' {
        Set-Variable -Option Constant Findings ([PSObject[]]@(Invoke-Linter $TestPaths $TestSettingsPath))

        @($Findings | ForEach-Object { "$($_.ScriptName) $($_.RuleName)" }) | Should -BeExactly @(
            'TEST_PATH_1 PSFirstRule'
            'TEST_PATH_1 PSSecondRule'
            'TEST_PATH_2 PSFirstRule'
            'TEST_PATH_2 PSSecondRule'
        )
    }

    It 'Should return nothing when no rule finds anything' {
        Mock Invoke-ScriptAnalyzer {}

        @(Invoke-Linter $TestPaths $TestSettingsPath) | Should -HaveCount 0
    }

    It "Should stop at an error of the analyzer's own, rather than report no findings" {
        Mock Invoke-ScriptAnalyzer { throw $TestException }

        { Invoke-Linter $TestPaths $TestSettingsPath } | Should -Throw $TestException

        Should -Invoke Invoke-ScriptAnalyzer -Exactly 1
    }
}
