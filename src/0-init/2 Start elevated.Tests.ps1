BeforeAll {
    # Dot-sourcing the script would restart the test run elevated — load only its function
    Set-Variable -Option Constant ScriptAst ([Management.Automation.Language.Parser]::ParseFile($PSCommandPath.Replace('.Tests.ps1', '.ps1'), [Ref]$Null, [Ref]$Null))
    foreach ($Function in $ScriptAst.FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $False)) {
        . ([ScriptBlock]::Create($Function.Extent.Text))
    }

    Set-Variable -Option Constant TestScriptPath ([String]'C:\Users\Test\AppData\Local\Temp\qiiwexc.ps1')
}

Describe 'Get-ElevationArguments' {
    It 'Should quote the paths' {
        Set-Variable -Option Constant Result ([String[]](Get-ElevationArguments $TestScriptPath 'C:\Some Dir'))

        $Result | Should -Be @('-ExecutionPolicy', 'Bypass', '-File', "`"$TestScriptPath`"", '-WorkingDirectory', '"C:\Some Dir"')
    }

    It 'Should pass dev mode on' {
        Set-Variable -Option Constant Result ([String[]](Get-ElevationArguments $TestScriptPath 'C:\Some Dir' -DevMode))

        $Result[-1] | Should -BeExactly '-DevMode'
    }

    It 'Should drop the trailing backslash of a drive root' {
        Set-Variable -Option Constant Result ([String[]](Get-ElevationArguments $TestScriptPath 'E:\'))

        $Result | Should -Contain '"E:"'
    }

    # What the elevated instance actually receives once Windows has parsed the command line —
    # started without elevation here, the parsing is the same
    It 'Should arrive intact in the started script: <WorkingDirectory>' -Skip:([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) -ForEach @(
        @{ WorkingDirectory = 'E:\'; Expected = 'E:' }
        @{ WorkingDirectory = 'C:\Some Dir'; Expected = 'C:\Some Dir' }
        @{ WorkingDirectory = "C:\Users\O'Brien (Home)\Downloads"; Expected = "C:\Users\O'Brien (Home)\Downloads" }
    ) {
        Set-Variable -Option Constant ScriptFile ([String]"$TestDrive\receiver.ps1")
        Set-Variable -Option Constant OutputFile ([String]"$TestDrive\received.txt")
        Set-Content $ScriptFile ('param([String]$WorkingDirectory, [Switch]$DevMode) Set-Content -LiteralPath "{0}" "$WorkingDirectory|$DevMode"' -f $OutputFile)

        Start-Process PowerShell -ArgumentList (@('-NoProfile') + (Get-ElevationArguments $ScriptFile $WorkingDirectory -DevMode)) -Wait -WindowStyle Hidden

        Get-Content -LiteralPath $OutputFile | Should -BeExactly "$Expected|True"
    }
}
