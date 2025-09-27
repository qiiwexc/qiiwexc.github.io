@{
    ExcludeRules = @(
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
        PSUseCompatibleCmdlets                     = @{
            compatibility = @('desktop-3.0-windows')
        }
    }
}
