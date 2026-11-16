BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Add-Type -AssemblyName PresentationFramework
}

# The box itself is modal and waits for a click, so only what it is given is checked: every value a caller may pass
# has to be one WPF knows, or the call fails at the moment it was needed
Describe 'Show-MessageBox' {
    # By name: the cases are read before BeforeAll loads WPF
    It 'Should accept only <Parameter> values that WPF has' -ForEach @(
        @{ Parameter = 'Buttons'; TypeName = 'Windows.MessageBoxButton' }
        @{ Parameter = 'Icon'; TypeName = 'Windows.MessageBoxImage' }
        @{ Parameter = 'Default'; TypeName = 'Windows.MessageBoxResult' }
    ) {
        Set-Variable -Option Constant ValidValues ([String[]]((Get-Command Show-MessageBox).Parameters[$Parameter].Attributes | Where-Object { $_ -is [Management.Automation.ValidateSetAttribute] }).ValidValues)

        $ValidValues | Should -Not -BeNullOrEmpty
        foreach ($Value in $ValidValues) {
            [Enum]::GetNames([Type]$TypeName) | Should -Contain $Value
        }
    }

    It 'Should default to values that WPF has' {
        Set-Variable -Option Constant Parameters ([Management.Automation.Language.ParameterAst[]](Get-Command Show-MessageBox).ScriptBlock.Ast.Body.ParamBlock.Parameters)

        foreach ($Parameter in ($Parameters | Where-Object { $_.DefaultValue })) {
            [String]$Default = $Parameter.DefaultValue.Value
            $Default | Should -BeIn @([Enum]::GetNames([Windows.MessageBoxButton]) + [Enum]::GetNames([Windows.MessageBoxImage]) + [Enum]::GetNames([Windows.MessageBoxResult]))
        }
    }
}
