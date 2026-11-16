BeforeAll {
    # Dot-sourcing the script would restart the test run elevated - load only its function
    Set-Variable -Option Constant ScriptAst ([Management.Automation.Language.Parser]::ParseFile($PSCommandPath.Replace('.Tests.ps1', '.ps1'), [Ref]$Null, [Ref]$Null))
    foreach ($Function in $ScriptAst.FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $False)) {
        . ([ScriptBlock]::Create($Function.Extent.Text))
    }

    Set-Variable -Option Constant TestScriptPath ([String]'C:\Users\Test\AppData\Local\Temp\qiiwexc.ps1')
    Set-Variable -Option Constant TestSha256 ([String]('AB' * 32))
    Set-Variable -Option Constant WindowsPowerShell ([String]"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe")
}

Describe 'Get-ElevationArguments' {
    It 'Should start PowerShell without the profile, with the command as one quoted argument' {
        Set-Variable -Option Constant Result ([String[]](Get-ElevationArguments $TestScriptPath $TestSha256 'C:\Some Dir'))

        $Result.Count | Should -Be 5
        $Result[0..3] | Should -Be @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command')
        $Result[4] | Should -BeLike '"*"'
        $Result[4].Trim('"') | Should -Not -BeLike '*"*'
    }

    It 'Should check the copy against the hash and run it from the system temp folder' {
        Set-Variable -Option Constant Result ([String](Get-ElevationArguments $TestScriptPath $TestSha256 'C:\Some Dir')[-1])

        $Result | Should -BeLike "*Copy-Item -LiteralPath '$TestScriptPath'*"
        $Result | Should -BeLike "*-ne '$TestSha256'*"
        $Result | Should -BeLike "*Join-Path `$env:SystemRoot ('Temp\qiiwexc_'*"
        $Result | Should -BeLike "*& `$Copy -WorkingDirectory 'C:\Some Dir'*"
        $Result | Should -Not -BeLike '*-DevMode*'
    }

    It 'Should pass dev mode on' {
        Set-Variable -Option Constant Result ([String](Get-ElevationArguments $TestScriptPath $TestSha256 'C:\Some Dir' -DevMode)[-1])

        $Result | Should -BeLike "*-WorkingDirectory 'C:\Some Dir' -DevMode *"
    }

    It 'Should drop the trailing backslash of a drive root' {
        Set-Variable -Option Constant Result ([String](Get-ElevationArguments $TestScriptPath $TestSha256 'E:\')[-1])

        $Result | Should -BeLike "*-WorkingDirectory 'E:'*"
    }

    It 'Should refuse a hash that is not a SHA-256 in hex: <Sha256>' -ForEach @(
        @{ Sha256 = 'ABC' }
        @{ Sha256 = "$('AB' * 31)'; x '" }
    ) {
        { Get-ElevationArguments $TestScriptPath $Sha256 'C:\' } | Should -Throw
    }

    # What the elevated instance actually runs once Windows has parsed the command line - started
    # without elevation here, the parsing and the bootstrap are the same
    Context 'Started in a real process' -Skip:([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        BeforeEach {
            Set-Variable -Option Constant ScriptFile ([String]"$TestDrive\receiver.ps1")
            Set-Variable -Option Constant OutputFile ([String]"$TestDrive\received.txt")
            Remove-Item -LiteralPath $OutputFile -ErrorAction SilentlyContinue
            Set-Content $ScriptFile ('param([String]$WorkingDirectory, [Switch]$DevMode) Set-Content -LiteralPath "{0}" "$WorkingDirectory|$DevMode|$PSCommandPath" -Encoding UTF8' -f $OutputFile)
        }

        It 'Should run a checked copy that receives its arguments intact: <WorkingDirectory>' -ForEach @(
            @{ WorkingDirectory = 'E:\'; Expected = 'E:' }
            @{ WorkingDirectory = 'C:\Some Dir'; Expected = 'C:\Some Dir' }
            @{ WorkingDirectory = "C:\Users\O'Brien (Home)\Downloads"; Expected = "C:\Users\O'Brien (Home)\Downloads" }
            @{ WorkingDirectory = "C:\Users\O$([Char]0x2019)Brien `$Home\Downloads"; Expected = "C:\Users\O$([Char]0x2019)Brien `$Home\Downloads" }
        ) {
            Set-Variable -Option Constant Hash ([String](Get-FileHash -LiteralPath $ScriptFile -Algorithm SHA256).Hash)

            Set-Variable -Option Constant ExitCode ([Int](Start-Process $WindowsPowerShell -ArgumentList (Get-ElevationArguments $ScriptFile $Hash $WorkingDirectory -DevMode) -Wait -PassThru -WindowStyle Hidden).ExitCode)

            $ExitCode | Should -Be 0
            [String[]]$Received = (Get-Content -LiteralPath $OutputFile -Encoding UTF8 -Raw).Trim().Split('|')
            $Received[0] | Should -BeExactly $Expected
            $Received[1] | Should -BeExactly 'True'
            $Received[2] | Should -BeLike "$env:SystemRoot\Temp\qiiwexc_*.ps1"
            Test-Path -LiteralPath $Received[2] | Should -BeFalse
        }

        It 'Should not run a script that changed after it was hashed' {
            Set-Variable -Option Constant ExitCode ([Int](Start-Process $WindowsPowerShell -ArgumentList (Get-ElevationArguments $ScriptFile $TestSha256 'C:\') -Wait -PassThru -WindowStyle Hidden).ExitCode)

            $ExitCode | Should -Be 1
            Test-Path -LiteralPath $OutputFile | Should -BeFalse
        }
    }
}
