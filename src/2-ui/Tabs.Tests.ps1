#pester:no-parallel - builds WPF controls, which need an STA thread, and parallel workers are MTA

BeforeAll {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore

    Set-Variable -Option Constant SourcePath ([String](Split-Path -Parent $PSScriptRoot))

    foreach ($Component in @(Get-ChildItem "$SourcePath\1-components" -Filter *.ps1 | Where-Object { $_.Name -notlike '*.Tests.ps1' })) {
        . $Component.FullName
    }

    Set-Variable -Option Constant FONT_NAME ([String]'Segoe UI')
    Set-Variable -Option Constant FONT_SIZE_NORMAL ([Int]12)
    Set-Variable -Option Constant FONT_SIZE_HEADER ([Int]16)
    Set-Variable -Option Constant CARD_COLUMN_WIDTH ([Int]230)
    Set-Variable -Option Constant IS_LAPTOP ([Bool]$False)

    Set-Variable -Option Constant FORM ([PSCustomObject]@{})
    $FORM | Add-Member -MemberType ScriptMethod -Name FindResource -Value { param($Key) return [Windows.Style]::new() }

    # The tab definitions: every file here but the window itself
    Set-Variable -Option Constant DefinitionFiles ([IO.FileInfo[]]@(Get-ChildItem $PSScriptRoot -Filter *.ps1 | Where-Object { $_.Name -notlike '*.Tests.ps1' -and $_.Name -ne 'Form.ps1' }))
    foreach ($DefinitionFile in $DefinitionFiles) {
        . $DefinitionFile.FullName
    }

    function Get-Ast {
        param(
            [Parameter(Position = 0, Mandatory)][String]$Path
        )

        return [Management.Automation.Language.Parser]::ParseFile($Path, [Ref]$Null, [Ref]$Null)
    }

    # The tabs the entry point renders, in its order
    Set-Variable -Option Constant EntryPoint ([String]"$SourcePath\5-interface\Show window.ps1")
    Set-Variable -Option Constant RenderedTabs ([String[]]@(
            (Get-Ast $EntryPoint).FindAll({ $args[0] -is [Management.Automation.Language.VariableExpressionAst] }, $True) |
                ForEach-Object { $_.VariablePath.UserPath } |
                Where-Object { $_ -like 'TAB_*' -and $_ -ne 'TAB_CONTROL' }
        ))

    Set-Variable -Option Constant TabControl ([Windows.Controls.TabControl]::new())
    Set-Variable -Option Constant CHECKBOXES ([Hashtable]@{})
    foreach ($Tab in $RenderedTabs) {
        New-Tab $TabControl (Get-Variable $Tab -ValueOnly) $CHECKBOXES
    }

    # Every checkbox name the code reads: $CHECKBOXES.Name and $CHECKBOXES['Name'] anywhere in the app, and the
    # names the handlers look up through a list
    [ScriptBlock]$IsCheckboxRead = {
        param($Node)

        # A method call such as $CHECKBOXES.ContainsKey() is a member expression too, but reads no checkbox
        [Object]$Target = if ($Node -is [Management.Automation.Language.IndexExpressionAst]) {
            $Node.Target
        } elseif ($Node -is [Management.Automation.Language.MemberExpressionAst] -and $Node -isnot [Management.Automation.Language.InvokeMemberExpressionAst]) {
            $Node.Expression
        }

        return $Target -is [Management.Automation.Language.VariableExpressionAst] -and $Target.VariablePath.UserPath -eq 'CHECKBOXES'
    }

    [String[]]$Files = @(Get-ChildItem $SourcePath -Recurse -Filter *.ps1 | Where-Object { $_.Name -notlike '*.Tests.ps1' } | ForEach-Object { $_.FullName })
    [String[]]$DirectReads = @(foreach ($File in $Files) {
            foreach ($Read in (Get-Ast $File).FindAll($IsCheckboxRead, $True)) {
                [Object]$Key = if ($Read -is [Management.Automation.Language.IndexExpressionAst]) { $Read.Index } else { $Read.Member }
                if ($Key -is [Management.Automation.Language.StringConstantExpressionAst]) {
                    $Key.Value
                }
            }
        })
    Set-Variable -Option Constant ReadNames ([String[]]@($DirectReads + $NINITE_CHECKBOX_NAMES + $APPS_CONFIGURATION_CHECKBOXES.Values + $WINDOWS_CONFIGURATION_CHECKBOXES.Values | Sort-Object -Unique))
}

Describe 'Tab definitions' {
    It 'Should all be rendered by the entry point' {
        [String[]]$Defined = @($DefinitionFiles | ForEach-Object {
                (Get-Ast $_.FullName).FindAll({ $args[0] -is [Management.Automation.Language.CommandAst] -and $args[0].GetCommandName() -eq 'Set-Variable' }, $True) |
                    ForEach-Object { $_.CommandElements | Where-Object { $_ -is [Management.Automation.Language.StringConstantExpressionAst] -and $_.Value -like 'TAB_*' } } |
                    ForEach-Object { $_.Value }
            })

        $RenderedTabs | Sort-Object | Should -BeExactly ($Defined | Sort-Object)
    }

    It 'Should render as tabs, in the order of the entry point' {
        @($TabControl.Items | ForEach-Object { $_.Header }) | Should -BeExactly @('Home', 'Installs', 'Configuration', 'Diagnostics and recovery')
    }

    It 'Should define every checkbox the code reads' {
        @($ReadNames | Where-Object { -not $CHECKBOXES.ContainsKey($_) }) | Should -BeNullOrEmpty
    }

    It 'Should read every checkbox it defines' {
        @($CHECKBOXES.Keys | Where-Object { $_ -notin $ReadNames }) | Should -BeNullOrEmpty
    }

    # The async runspace gets copies of the app's functions and of the variables it is handed, not the
    # handler's scope, so a variable read in an operation that is not passed in is silently $Null there
    It 'Should pass every variable an async operation reads' {
        [String[]]$Injected = @((Get-Ast "$SourcePath\4-functions\Common\Start-AsyncOperation.ps1").FindAll({ $args[0] -is [Management.Automation.Language.StringConstantExpressionAst] }, $True) |
                ForEach-Object { $_.Value } |
                Where-Object { $_ -cmatch '^[A-Z][A-Z0-9_]*$' })
        [String[]]$Automatic = @('this', '_', 'PSItem', 'true', 'false', 'null', 'args', 'input')

        [String[]]$Problems = @(foreach ($DefinitionFile in $DefinitionFiles) {
                foreach ($Call in (Get-Ast $DefinitionFile.FullName).FindAll({ $args[0] -is [Management.Automation.Language.CommandAst] -and $args[0].GetCommandName() -eq 'Start-AsyncOperation' }, $True)) {
                    [Object[]]$Elements = $Call.CommandElements
                    [String[]]$Passed = @()
                    [Object]$Operation = $Null
                    for ($Index = 1; $Index -lt $Elements.Count; $Index++) {
                        [Object]$Previous = $Elements[$Index - 1]
                        [Bool]$AfterParameter = $Previous -is [Management.Automation.Language.CommandParameterAst]
                        if ($AfterParameter -and $Previous.ParameterName -eq 'Variables') {
                            $Passed = @($Elements[$Index].KeyValuePairs | ForEach-Object { $_.Item1.Value })
                        } elseif ($Elements[$Index] -is [Management.Automation.Language.ScriptBlockExpressionAst] -and -not ($AfterParameter -and $Previous.ParameterName -eq 'OnComplete')) {
                            $Operation = $Elements[$Index]
                        }
                    }

                    [String[]]$Assigned = @($Operation.FindAll({ $args[0] -is [Management.Automation.Language.AssignmentStatementAst] }, $True) | ForEach-Object { $_.Left.VariablePath.UserPath })
                    foreach ($Variable in @($Operation.FindAll({ $args[0] -is [Management.Automation.Language.VariableExpressionAst] }, $True) | ForEach-Object { $_.VariablePath.UserPath } | Sort-Object -Unique)) {
                        if ($Variable -notin ($Passed + $Assigned + $Injected + $Automatic) -and $Variable -notlike 'CONFIG_*') {
                            "$($DefinitionFile.Name), line $($Call.Extent.StartLineNumber): `$$Variable is not passed"
                        }
                    }
                }
            })

        $Problems | Should -BeNullOrEmpty
    }
}
