BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . "$PSScriptRoot\..\App lifecycle\Logger.ps1"

    # The native calls '3 Initialization.ps1' defines, pulled out through the parser: the script itself would start the app
    if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
        Set-Variable -Option Constant AddType ([Management.Automation.Language.CommandAst]([Management.Automation.Language.Parser]::ParseFile("$PSScriptRoot\..\..\0-init\3 Initialization.ps1", [Ref]$Null, [Ref]$Null).Find({
                        $args[0] -is [Management.Automation.Language.CommandAst] -and
                        $args[0].GetCommandName() -eq 'Add-Type' -and
                        $args[0].Extent.Text -match 'NativeMethods'
                    }, $True)))
        Add-Type -TypeDefinition ([String]$AddType.CommandElements[-1].Value)
    }
}

Describe 'Get-ChkDskYesKey' -Skip:([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    BeforeAll {
        Mock Write-LogDebug {}
    }

    It "Should answer with the first letter of Windows' word for Yes" {
        Set-Variable -Option Constant PATH_SYSTEM_32 ([String]"$env:SystemRoot\System32")

        Set-Variable -Option Constant YesKey ([String](Get-ChkDskYesKey))

        $YesKey.Length | Should -Be 1 -Because 'chkdsk reads the first letter only'
        [Char]::IsLetter($YesKey[0]) | Should -BeTrue

        Should -Invoke Write-LogDebug -Exactly 0
    }

    It 'Should answer Y on a system displayed in English' -Skip:([Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName -ne 'en') {
        Set-Variable -Option Constant PATH_SYSTEM_32 ([String]"$env:SystemRoot\System32")

        Get-ChkDskYesKey | Should -BeExactly 'Y'
    }

    It 'Should answer Y when the messages cannot be read' {
        Set-Variable -Option Constant PATH_SYSTEM_32 ([String]"$TestDrive\System32")

        Get-ChkDskYesKey | Should -BeExactly 'Y'

        Should -Invoke Write-LogDebug -Exactly 1
    }
}
