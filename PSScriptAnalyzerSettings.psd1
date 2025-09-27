@{
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns'
    )
    Rules        = @{
        PSAlignAssignmentStatement                 = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSAvoidExclaimOperator                     = @{
            Enable = $true
        }
        PSAvoidSemicolonsAsLineTerminators         = @{
            Enable = $true
        }
        PSAvoidUsingDoubleQuotesForConstantStrings = @{
            Enable = $true
        }
        PSPlaceCloseBrace                          = @{
            Enable             = $true
            IgnoreOneLineBlock = $true
            NewLineAfter       = $false
        }
        PSPlaceOpenBrace                           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSUseCompatibleCmdlets                     = @{
            compatibility = @('desktop-3.0-windows')
        }
        PSUseCompatibleSyntax                      = @{
            Enable         = $true
            TargetVersions = @(
                '7.1',
                '7.0',
                '6.2',
                '6.1',
                '6.0',
                '5.1',
                '4.0',
                '3.0',
                '2.0'
            )
        }
        PSUseConsistentIndentation                 = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
        PSUseCorrectCasing                         = @{
            Enable        = $true
            CheckCommands = $true
            CheckKeyword  = $true
            CheckOperator = $true
        }
    }
}
