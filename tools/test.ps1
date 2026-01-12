#Requires -Version 5

param(
    [Switch]$Coverage,
    [Switch]$Wip
)

Set-Variable -Option Constant Tag $(if ($Wip) { 'WIP' } else { $Null })

Set-Variable -Option Constant PesterOptions @{
    Run          = @{
        Path = @(
            'tools\common',
            'tools\build',
            'src\4-functions\Common',
            'src\4-functions\Diagnostics and recovery',
            'src\4-functions\Home',
            'src\4-functions\Installs'
        )
    }
    Filter       = @{
        Tag = $Tag
    }
    CodeCoverage = @{
        Enabled    = $Coverage.ToBool()
        OutputPath = 'build\coverage.xml'
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
}

Set-Variable -Option Constant PesterConfig (New-PesterConfiguration -Hashtable $PesterOptions)

Invoke-Pester -Configuration $PesterConfig
