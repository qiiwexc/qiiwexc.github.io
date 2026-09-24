BeforeAll {
    Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent $PSScriptRoot))

    # A mock should behave like the function it replaces — a test that makes a function throw
    # when the real one cannot proves only how the caller copes with something that never happens.
    # Returns '<src|tools>:<name>' for every function whose whole body is a single try statement with
    # a catch-all clause that never rethrows, preceded at most by constant declarations
    function Get-NonThrowingFunctions {
        Set-Variable -Option Constant ConstantDeclarationPattern ([String]'^Set-Variable -Option Constant \w+ \(\[[\w.]+\][^$()]*\)$')

        foreach ($Area in @('src', 'tools')) {
            foreach ($File in (Get-ChildItem "$ProjectRoot\$Area" -Recurse -Filter *.ps1 | Where-Object { $_.Name -notlike '*.Tests.ps1' })) {
                [Management.Automation.Language.ScriptBlockAst]$Ast = [Management.Automation.Language.Parser]::ParseFile($File.FullName, [Ref]$Null, [Ref]$Null)
                foreach ($Function in $Ast.FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $True)) {
                    [Management.Automation.Language.ScriptBlockAst]$Body = $Function.Body
                    if ($Body.BeginBlock -or $Body.ProcessBlock -or -not $Body.EndBlock -or $Body.EndBlock.Statements.Count -eq 0) {
                        continue
                    }

                    [Object[]]$Statements = @($Body.EndBlock.Statements)
                    [Object]$Try = $Statements[-1]
                    if ($Try -isnot [Management.Automation.Language.TryStatementAst] -or $Try.Finally) {
                        continue
                    }
                    if (@($Statements | Select-Object -SkipLast 1 | Where-Object { $_.Extent.Text -notmatch $ConstantDeclarationPattern }).Count -gt 0) {
                        continue
                    }
                    if (-not @($Try.CatchClauses | Where-Object { $_.IsCatchAll }).Count) {
                        continue
                    }
                    if (@($Try.CatchClauses | ForEach-Object { $_.Body.FindAll({ $args[0] -is [Management.Automation.Language.ThrowStatementAst] }, $True) }).Count -gt 0) {
                        continue
                    }

                    "${Area}:$($Function.Name)"
                }
            }
        }
    }

    # Returns '<file>:<line> Mock <name>' for every mock that throws in place of a function that cannot
    function Get-ThrowingMocksOfNonThrowingFunctions {
        param(
            [Parameter(Position = 0, Mandatory)][String[]]$NonThrowingFunctions
        )

        foreach ($Area in @('src', 'tools')) {
            foreach ($File in (Get-ChildItem "$ProjectRoot\$Area" -Recurse -Filter *.Tests.ps1)) {
                [Management.Automation.Language.ScriptBlockAst]$Ast = [Management.Automation.Language.Parser]::ParseFile($File.FullName, [Ref]$Null, [Ref]$Null)
                foreach ($Command in $Ast.FindAll({ $args[0] -is [Management.Automation.Language.CommandAst] -and $args[0].GetCommandName() -eq 'Mock' }, $True)) {
                    [String]$Name = ''
                    [Object]$MockWith = $Null
                    [String]$PreviousParameter = ''

                    foreach ($Element in ($Command.CommandElements | Select-Object -Skip 1)) {
                        if ($Element -is [Management.Automation.Language.CommandParameterAst]) {
                            $PreviousParameter = $Element.ParameterName
                            continue
                        }
                        if (-not $Name -and $Element -is [Management.Automation.Language.StringConstantExpressionAst] -and $PreviousParameter -notin @('ParameterFilter', 'MockWith')) {
                            $Name = $Element.Value
                        } elseif (-not $MockWith -and $Element -is [Management.Automation.Language.ScriptBlockExpressionAst] -and $PreviousParameter -ne 'ParameterFilter') {
                            $MockWith = $Element
                        }
                        $PreviousParameter = ''
                    }

                    if ("${Area}:$Name" -in $NonThrowingFunctions -and $MockWith -and $MockWith.FindAll({ $args[0] -is [Management.Automation.Language.ThrowStatementAst] }, $True).Count -gt 0) {
                        '{0}:{1} Mock {2}' -f $File.FullName.Substring($ProjectRoot.Length + 1), $Command.Extent.StartLineNumber, $Name
                    }
                }
            }
        }
    }
}

Describe 'Mocks' {
    BeforeAll {
        Set-Variable -Option Constant NonThrowingFunctions ([String[]](Get-NonThrowingFunctions))
    }

    It 'Should find the functions that cannot throw' {
        # Guards the detection itself: known non-throwing functions must be recognised,
        # and a function that rethrows must not be
        $NonThrowingFunctions | Should -Contain 'src:Test-UpdateAvailability'
        $NonThrowingFunctions | Should -Contain 'src:Update-BrowserConfiguration'
        $NonThrowingFunctions | Should -Not -Contain 'src:Import-RegistryConfiguration'
        $NonThrowingFunctions | Should -Not -Contain 'tools:Set-MalwareProtectionConfiguration'
    }

    It 'Should not make a function throw that cannot throw' {
        Get-ThrowingMocksOfNonThrowingFunctions $NonThrowingFunctions | Should -BeNullOrEmpty
    }
}
