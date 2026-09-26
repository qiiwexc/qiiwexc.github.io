param(
    [Switch]$Coverage,
    [Switch]$Wip
)

# Paths are absolute, so the suite behaves the same whatever the current directory is
@{
    Run          = @{
        Exit     = $True
        # Test files run in parallel, each in a runspace of its own. A file that builds WPF controls (they
        # need an STA thread, and the workers' are MTA) or changes process-wide state (environment
        # variables, the current directory, the console encoding) carries '#pester:no-parallel', and runs
        # in this session once the parallel batch is done. Not with coverage: every worker then sets
        # breakpoints on all the measured files, which made a 108-second run take 658
        Parallel = -not $Coverage.ToBool()
        # Where Pester starts looking for Pester.BeforeContainer.ps1, which gives the workers the strict
        # mode and error preference of tools\test.ps1
        RepoRoot = $PSScriptRoot
        Path     = @(
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
