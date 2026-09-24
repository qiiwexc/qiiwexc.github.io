BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\..\common\logger.ps1"
    . "$PSScriptRoot\..\..\common\types.ps1"

    Set-Variable -Option Constant TestVersion ([String]'2.0.0')
    Set-Variable -Option Constant TestDependency ([Dependency]@{ version = '1.0.0' })
}

Describe 'Set-NewVersion' {
    BeforeAll {
        Mock Write-LogInfo {}
    }

    It 'Should set new version' {
        Set-NewVersion $TestDependency $TestVersion

        $TestDependency.version | Should -BeExactly $TestVersion
    }
}
