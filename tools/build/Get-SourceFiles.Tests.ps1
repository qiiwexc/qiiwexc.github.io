BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestSourcePath ([String]"$TestDrive\src")

    # Created in an order unlike the expected one, so the result cannot come from creation order
    foreach ($File in @(
            '2-ui\Tabs\Home.ps1',
            '2-ui\Form.ps1',
            '2-ui\Tabs b\Other.ps1',
            '2-ui\a.ps1',
            '2-ui\B.ps1',
            '1-components\Button.ps1',
            '1-components\Button.Tests.ps1',
            '0-init\1 Version.ps1',
            '0-init\0 Parameters.ps1',
            '3-configs\Windows\Baseline.reg'
        )) {
        $Null = New-Item -ItemType File -Force "$TestSourcePath\$File"
    }
}

Describe 'Get-SourceFiles' {
    It 'Should list files before subdirectories, each level in name order, without tests' {
        Set-Variable -Option Constant Result ([String[]]@(Get-SourceFiles $TestSourcePath | ForEach-Object { $_.FullName.Substring($TestSourcePath.Length + 1) }))

        $Result | Should -BeExactly @(
            '0-init\0 Parameters.ps1',
            '0-init\1 Version.ps1',
            '1-components\Button.ps1',
            '2-ui\a.ps1',
            '2-ui\B.ps1',
            '2-ui\Form.ps1',
            '2-ui\Tabs\Home.ps1',
            '2-ui\Tabs b\Other.ps1',
            '3-configs\Windows\Baseline.reg'
        )
    }

    It 'Should return file objects' {
        Get-SourceFiles $TestSourcePath | ForEach-Object { $_ | Should -BeOfType [IO.FileInfo] }
    }

    It 'Should fail for a missing source path' {
        { Get-SourceFiles "$TestDrive\missing" } | Should -Throw
    }
}
