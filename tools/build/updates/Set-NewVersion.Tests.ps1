BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'

    Set-Variable -Option Constant TestVersion ([String]'2.0.0')
    Set-Variable -Option Constant TestDependency ([PSCustomObject]@{ version = '1.0.0' })
}

Describe 'Set-NewVersion' {
    BeforeEach {
        Mock Write-LogInfo {}
    }

    It 'Should set new version' {
        Set-NewVersion $TestDependency $TestVersion

        $TestDependency.version | Should -BeExactly $TestVersion
    }
}
