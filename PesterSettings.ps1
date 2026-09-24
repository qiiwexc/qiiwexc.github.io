param(
    [Switch]$Coverage,
    [Switch]$Wip
)

# Paths are absolute, so the suite behaves the same whatever the current directory is
@{
    Run          = @{
        Exit = $True
        Path = @(
            "$PSScriptRoot\tools",
            "$PSScriptRoot\src\0-init",
            "$PSScriptRoot\src\1-components",
            "$PSScriptRoot\src\3-configs",
            "$PSScriptRoot\src\4-functions"
        )
    }
    Filter       = @{
        Tag = $(if ($Wip) { 'WIP' } else { $Null })
    }
    CodeCoverage = @{
        Enabled    = $Coverage.ToBool()
        # Start-up scripts (0-init) and data files (3-configs) are checked by tests but not measured
        Path       = @(
            "$PSScriptRoot\tools\common",
            "$PSScriptRoot\tools\build",
            "$PSScriptRoot\src\1-components",
            "$PSScriptRoot\src\4-functions"
        )
        OutputPath = "$PSScriptRoot\build\coverage.xml"
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
}
