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
            'src\4-functions'
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
