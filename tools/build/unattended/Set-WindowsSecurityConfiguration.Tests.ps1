BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant SourcePath ([String]'.\src')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{WINDOWS_SECURITY_CONFIGURATION}`nTEST_TEMPLATE_CONTENT_2")

    Set-Variable -Option Constant TestFilePath ([String]"$SourcePath\4-functions\Configuration\Windows\Set-WindowsSecurityConfiguration.ps1")
}

Describe 'Set-WindowsSecurityConfiguration' {
    It 'Should inline Windows security configuration correctly' {
        Set-Variable -Option Constant Result (Set-WindowsSecurityConfiguration $SourcePath $TestTemplateContent)

        $Result | Should -Match 'Set-MpPreference -CheckForSignaturesBefore \$True'
        $Result | Should -Match 'Set-MpPreference -DisableBlockAtFirstSeen \$False'
        $Result | Should -Match 'Set-MpPreference -DisableCatchupQuickScan \$False'
        $Result | Should -Match 'Set-MpPreference -DisableEmailScanning \$False'
        $Result | Should -Match 'Set-MpPreference -DisableRemovableDriveScanning \$False'
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { Set-WindowsSecurityConfiguration $SourcePath $TestTemplateContent } | Should -Throw

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestFilePath -and
            $Encoding -eq 'UTF8'
        }
    }
}
