BeforeAll {
    # Loading the script would extract the icons straight away, with the native calls '3 Initialization.ps1' defines.
    # Both are pulled out through the parser: the type from the one, the function from the other
    function Get-ScriptAst([String]$FileName) {
        return [Management.Automation.Language.Parser]::ParseFile("$PSScriptRoot\$FileName", [Ref]$Null, [Ref]$Null)
    }

    if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
        Add-Type -AssemblyName System.Drawing

        Set-Variable -Option Constant AddType ([Management.Automation.Language.CommandAst]((Get-ScriptAst '3 Initialization.ps1').Find({
                        $args[0] -is [Management.Automation.Language.CommandAst] -and
                        $args[0].GetCommandName() -eq 'Add-Type' -and
                        $args[0].Extent.Text -match 'NativeMethods'
                    }, $True)))
        Add-Type -TypeDefinition ([String]$AddType.CommandElements[-1].Value)
    }

    foreach ($Function in (Get-ScriptAst $PSCommandPath.Split('\')[-1].Replace('.Tests.ps1', '.ps1')).FindAll({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $False)) {
        . ([ScriptBlock]::Create($Function.Extent.Text))
    }

    Set-Variable -Option Constant PATH_SYSTEM_32 ([String]"$env:SystemRoot\System32")
}

Describe 'Get-DllIcon' -Skip:([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    It 'Should extract the icon with resource ID <ResourceId>, which the window uses' -ForEach @(
        @{ ResourceId = 198 }
        @{ ResourceId = 1401 }
    ) {
        Set-Variable -Option Constant Icon ([Drawing.Icon](Get-DllIcon $ResourceId))

        $Icon | Should -Not -BeNullOrEmpty
        $Icon.Handle | Should -Not -Be ([IntPtr]::Zero)

        # Not the fallback: the same size, but other pixels
        [Drawing.Bitmap]$Bitmap = $Icon.ToBitmap()
        [Drawing.Bitmap]$Fallback = [Drawing.SystemIcons]::Application.ToBitmap()
        [Collections.Generic.List[Bool]]$Differences = @()
        for ([Int]$i = 0; $i -lt [Math]::Min($Bitmap.Width, $Fallback.Width); $i += 4) {
            $Differences.Add($Bitmap.GetPixel($i, $i) -ne $Fallback.GetPixel($i, $i))
        }
        $Differences | Should -Contain $True
    }

    It 'Should fall back to the application icon for a resource ID that does not exist' {
        Set-Variable -Option Constant Icon ([Drawing.Icon](Get-DllIcon 99999))

        $Icon | Should -Not -BeNullOrEmpty
        $Icon.Handle | Should -Not -Be ([IntPtr]::Zero)
        $Icon.Size | Should -Be ([Drawing.SystemIcons]::Application.Size)
    }
}
