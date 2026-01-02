Set-Variable -Option Constant PesterOptions @{
    CodeCoverage = @{
        Enabled    = $true
        OutputPath = 'build\coverage.xml'
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
}

Set-Variable -Option Constant PesterConfig (New-PesterConfiguration -Hashtable $PesterOptions)

Invoke-Pester -Configuration $PesterConfig
