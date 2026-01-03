@{
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns'
    )
    Rules        = @{
        PSAlignAssignmentStatement                 = @{
            Enable         = $True
            CheckHashtable = $True
        }
        PSAvoidExclaimOperator                     = @{
            Enable = $True
        }
        PSAvoidSemicolonsAsLineTerminators         = @{
            Enable = $True
        }
        PSAvoidUsingDoubleQuotesForConstantStrings = @{
            Enable = $True
        }
        PSPlaceCloseBrace                          = @{
            Enable             = $True
            IgnoreOneLineBlock = $True
            NewLineAfter       = $False
        }
        PSPlaceOpenBrace                           = @{
            Enable             = $True
            OnSameLine         = $True
            NewLineAfter       = $True
            IgnoreOneLineBlock = $True
        }
        PSUseCompatibleCmdlets                     = @{
            compatibility = @('desktop-4.0-windows')
        }
        PSUseCompatibleSyntax                      = @{
            Enable         = $True
            TargetVersions = @(
                '7.1',
                '7.0',
                '6.2',
                '6.1',
                '6.0',
                '5.1',
                '4.0',
                '3.0'
            )
        }
        PSUseConsistentIndentation                 = @{
            Enable              = $True
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
        PSUseCorrectCasing                         = @{
            Enable        = $True
            CheckCommands = $True
            CheckKeyword  = $True
            CheckOperator = $True
        }
    }
}
