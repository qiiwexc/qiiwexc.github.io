BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-ContrastingTextColor' {
    It 'Should pick <Expected> text on <Background>' -ForEach @(
        @{ Background = '#0067c0'; Expected = '#ffffff' } # Default Windows blue
        @{ Background = '#FFB900'; Expected = '#000000' } # Windows yellow accent
        @{ Background = '#00CC6A'; Expected = '#000000' } # Windows light green accent
        @{ Background = '#C42B1C'; Expected = '#ffffff' } # Red
        @{ Background = '#000000'; Expected = '#ffffff' }
        @{ Background = '#ffffff'; Expected = '#000000' }
    ) {
        Get-ContrastingTextColor $Background | Should -BeExactly $Expected
    }
}
