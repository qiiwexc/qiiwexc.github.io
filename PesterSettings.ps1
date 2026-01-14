param(
    [Switch]$Coverage,
    [Switch]$Wip
)

@{
    Run          = @{
        Exit = $True
        Path = @(
            'tools\common',
            'tools\build',
            'src\1-components',
            'src\4-functions\Common',
            'src\4-functions\Diagnostics and recovery',
            'src\4-functions\Home',
            'src\4-functions\Installs'
        )
    }
    Filter       = @{
        Tag = $(if ($Wip) { 'WIP' } else { $Null })
    }
    CodeCoverage = @{
        Enabled    = $Coverage.ToBool()
        OutputPath = 'build\coverage.xml'
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
}
