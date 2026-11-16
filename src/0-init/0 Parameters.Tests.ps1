BeforeAll {
    Set-Variable -Option Constant ScriptPath ([String]$PSCommandPath.Replace('.Tests.ps1', '.ps1'))
}

Describe 'Parameters' {
    It 'Should work in the folder of the script when started without a working directory' {
        Set-Variable -Option Constant Result ([String](& { . $ScriptPath; $WorkingDirectory }))

        $Result | Should -BeExactly (Split-Path -Parent $ScriptPath)
    }

    It 'Should work in the working directory it is given' {
        Set-Variable -Option Constant Result ([String](& { . $ScriptPath -WorkingDirectory 'C:\TEST_DIR'; $WorkingDirectory }))

        $Result | Should -BeExactly 'C:\TEST_DIR'
    }
}
