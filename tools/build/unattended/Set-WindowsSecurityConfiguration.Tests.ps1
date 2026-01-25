BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Read-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant SourcePath ([String]'.\src')
    Set-Variable -Option Constant TestTemplateContent ([String]"TEST_TEMPLATE_CONTENT_1`n{WINDOWS_SECURITY_CONFIGURATION}`nTEST_TEMPLATE_CONTENT_2")

    Set-Variable -Option Constant TestFilePath ([String]"$SourcePath\4-functions\Configuration\Windows\Set-WindowsSecurityConfiguration.ps1")
    Set-Variable -Option Constant TestFileContent (
        [String[]]@('    Set-MpPreference -CheckForSignaturesBefore $True',
            '    Set-MpPreference -DisableBlockAtFirstSeen $False',
            '    Set-MpPreference -DisableCatchupQuickScan $False',
            '    Set-MpPreference -DisableEmailScanning $False',
            '    Set-MpPreference -DisableRemovableDriveScanning $False')
    )
}

Describe 'Set-WindowsSecurityConfiguration' {
    BeforeEach {
        Mock Read-TextFile { return $TestFileContent }
    }

    It 'Should inline Windows security configuration correctly' {
        Set-Variable -Option Constant Result (Set-WindowsSecurityConfiguration $SourcePath $TestTemplateContent)

        $Result | Should -BeExactly 'TEST_TEMPLATE_CONTENT_1
Set-MpPreference -CheckForSignaturesBefore $True
Set-MpPreference -DisableBlockAtFirstSeen $False
Set-MpPreference -DisableCatchupQuickScan $False
Set-MpPreference -DisableEmailScanning $False
Set-MpPreference -DisableRemovableDriveScanning $False

TEST_TEMPLATE_CONTENT_2'

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestFilePath -and
            $AsList -eq $True
        }
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { Set-WindowsSecurityConfiguration $SourcePath $TestTemplateContent } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 1
    }
}
