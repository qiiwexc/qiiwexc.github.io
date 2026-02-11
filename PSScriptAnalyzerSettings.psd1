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
            compatibility = @('desktop-5.1.14393.206-windows')
        }
        PSUseCompatibleSyntax                      = @{
            Enable         = $True
            TargetVersions = @(
                '7.6',
                '7.5',
                '7.4',
                '7.3',
                '7.2',
                '7.1',
                '7.0',
                '6.2',
                '6.1',
                '6.0',
                '5.1'
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
