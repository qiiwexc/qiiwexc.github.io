$options = @{
    CodeCoverage = @{
        Enabled = $true
    }
    Output       = @{
        Verbosity = 'Detailed'
    }
}

$config = New-PesterConfiguration -Hashtable $options

Invoke-Pester -Configuration $config
