param(
    [Switch]$Coverage,
    [Switch]$Wip
)

Set-Variable -Option Constant CoverageEnabled $(if ($Coverage) { $True } else { $False })
Set-Variable -Option Constant Tag $(if ($Wip) { 'WIP' } else { $Null })

Set-Variable -Option Constant PesterOptions @{
    Run          = @{
        Path = @('src', 'tools')
    }
    Filter       = @{
        Tag = $Tag
    }
    CodeCoverage = @{
        Enabled    = $CoverageEnabled
        OutputPath = 'build\coverage.xml'
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
}

Set-Variable -Option Constant PesterConfig (New-PesterConfiguration -Hashtable $PesterOptions)

Invoke-Pester -Configuration $PesterConfig
