BeforeAll {
    Set-Variable -Option Constant ProjectRoot ([String](Split-Path -Parent $PSScriptRoot))

    . "$PSScriptRoot\build\Get-SourceFiles.ps1"

    # The scripts the build joins into the bundle, parsed one by one
    Set-Variable -Option Constant BundleAsts ([Management.Automation.Language.ScriptBlockAst[]]@(
            Get-SourceFiles "$ProjectRoot\src" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object {
                [Management.Automation.Language.Parser]::ParseFile($_.FullName, [Ref]$Null, [Ref]$Null)
            }
        ))

    Set-Variable -Option Constant BundleFunctions ([Collections.Generic.Dictionary[String, Management.Automation.Language.FunctionDefinitionAst]]::new([StringComparer]::OrdinalIgnoreCase))
    foreach ($Function in $BundleAsts.FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $True)) {
        $BundleFunctions[$Function.Name] = $Function
    }

    # The cmdlets of Windows PowerShell's own modules, the same on every Windows 10 and 11
    Set-Variable -Option Constant CoreCommands ([Collections.Generic.HashSet[String]]::new([String[]]@(
                Get-Command -Module 'Microsoft.PowerShell.Core', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility', 'Microsoft.PowerShell.Security' |
                    ForEach-Object { $_.Name }
            ), [StringComparer]::OrdinalIgnoreCase))

    # Every other command the bundle calls, with the module or the part of Windows it comes from. A command belongs here
    # only once it is certain to exist on every Windows the app accepts, or the code checks for it before relying on it:
    # one that a machine may lack fails there with "not recognised", wherever it is called from
    Set-Variable -Option Constant SystemCommands ([Hashtable]@{
            'chkdsk'                           = 'Windows'
            'powercfg'                         = 'Windows'
            'Start-BitsTransfer'               = 'BitsTransfer'
            'Complete-BitsTransfer'            = 'BitsTransfer'
            'Get-BitsTransfer'                 = 'BitsTransfer'
            'Remove-BitsTransfer'              = 'BitsTransfer'
            'Get-CimInstance'                  = 'CimCmdlets'
            'Invoke-CimMethod'                 = 'CimCmdlets'
            'Get-DnsClientServerAddress'       = 'DnsClient'
            'Set-DnsClientServerAddress'       = 'DnsClient'
            'Expand-Archive'                   = 'Microsoft.PowerShell.Archive'
            'Get-ScheduledTask'                = 'ScheduledTasks'
            'Disable-ScheduledTask'            = 'ScheduledTasks'
            'Unregister-ScheduledTask'         = 'ScheduledTasks'
            'Get-WinUserLanguageList'          = 'International'
            'Set-WinUserLanguageList'          = 'International'
            'Set-WinHomeLocation'              = 'International'
            'Delete-DeliveryOptimizationCache' = 'DeliveryOptimization'
            # Only where Microsoft Defender is installed: the app asks Get-MpComputerStatus first, inside a try
            'Get-MpComputerStatus'             = 'Defender'
            'Set-MpPreference'                 = 'Defender'
        })

    # '<file>:<line> <name>' for every command the given code calls by a name written out, and, as '<name> (dispatched)',
    # for every command it hands Invoke-OnDispatcher, which the UI thread then calls by that name
    function Get-CommandCalls {
        param(
            [Parameter(Position = 0, Mandatory)][Management.Automation.Language.Ast[]]$Asts
        )

        foreach ($Command in $Asts.FindAll({ $args[0] -is [Management.Automation.Language.CommandAst] }, $True)) {
            [String]$Name = $Command.GetCommandName()
            if (-not $Name) {
                continue
            }

            [String]$Location = '{0}:{1}' -f $Command.Extent.File.Substring($ProjectRoot.Length + 1), $Command.Extent.StartLineNumber
            [PSCustomObject]@{ Name = $Name; Location = $Location; Dispatched = $False; Command = $Command }

            if ($Name -eq 'Invoke-OnDispatcher' -and $Command.CommandElements.Count -gt 1 -and $Command.CommandElements[1] -is [Management.Automation.Language.StringConstantExpressionAst]) {
                [PSCustomObject]@{ Name = $Command.CommandElements[1].Value; Location = $Location; Dispatched = $True; Command = $Command }
            }
        }
    }

    # A function that declares no parameter and never reads $args: it silently drops whatever it is passed
    function Test-TakesNoArguments {
        param(
            [Parameter(Position = 0, Mandatory)][Management.Automation.Language.FunctionDefinitionAst]$Function
        )

        if ($Function.Parameters -or ($Function.Body.ParamBlock -and $Function.Body.ParamBlock.Parameters.Count -gt 0)) {
            return $False
        }

        return -not $Function.Body.Find({ $args[0] -is [Management.Automation.Language.VariableExpressionAst] -and $args[0].VariablePath.UserPath -eq 'args' }, $True)
    }

    Set-Variable -Option Constant BundleCalls ([PSCustomObject[]]@(Get-CommandCalls $BundleAsts))
}

Describe 'Bundle' -Skip:($PSVersionTable.PSEdition -ne 'Desktop') {
    It 'Should find the commands the bundle calls' {
        # Guards the detection itself: a function, a cmdlet, a Windows tool, and a command handed to the UI thread
        @($BundleCalls | ForEach-Object { $_.Name }) | Should -Contain 'Start-AsyncOperation'
        @($BundleCalls | ForEach-Object { $_.Name }) | Should -Contain 'Set-Variable'
        @($BundleCalls | ForEach-Object { $_.Name }) | Should -Contain 'chkdsk'
        @($BundleCalls | Where-Object { $_.Dispatched } | ForEach-Object { $_.Name }) | Should -Contain 'Set-ProgressBarValue'
        $BundleFunctions.Keys | Should -Contain 'Get-ChkDskYesKey'
    }

    It 'Should call only commands that the bundle defines or that Windows has' {
        [String[]]$Unknown = @($BundleCalls | Where-Object {
                -not $BundleFunctions.ContainsKey($_.Name) -and
                ($_.Dispatched -or (-not $CoreCommands.Contains($_.Name) -and -not $SystemCommands.ContainsKey($_.Name)))
            } | ForEach-Object { "$($_.Location) $($_.Name)" })

        $Unknown | Should -BeNullOrEmpty
    }

    It 'Should list only system commands that the bundle calls' {
        [String[]]$Called = @($BundleCalls | ForEach-Object { $_.Name })

        @($SystemCommands.Keys | Where-Object { $_ -notin $Called }) | Should -BeNullOrEmpty
    }

    It 'Should pass nothing to a function that takes nothing, in the bundle or in its tests' {
        Set-Variable -Option Constant TestAsts ([Management.Automation.Language.ScriptBlockAst[]]@(
                Get-ChildItem "$ProjectRoot\src" -Recurse -Filter '*.Tests.ps1' | ForEach-Object {
                    [Management.Automation.Language.Parser]::ParseFile($_.FullName, [Ref]$Null, [Ref]$Null)
                }
            ))

        [Collections.Generic.List[String]]$Ignored = @()
        foreach ($Ast in @($BundleAsts) + @($TestAsts)) {
            # A test's own stand-in for a function takes what it declares, not what the bundle's does
            [String[]]$LocalFunctions = @($Ast.FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $True) | ForEach-Object { $_.Name })

            foreach ($Call in (Get-CommandCalls $Ast | Where-Object { -not $_.Dispatched })) {
                if ($Call.Command.CommandElements.Count -gt 1 -and $BundleFunctions.ContainsKey($Call.Name) -and
                    ($Ast -in $BundleAsts -or $Call.Name -notin $LocalFunctions) -and (Test-TakesNoArguments $BundleFunctions[$Call.Name])) {
                    $Ignored.Add("$($Call.Location) $($Call.Command.Extent.Text)")
                }
            }
        }

        $Ignored | Should -BeNullOrEmpty
    }
}
