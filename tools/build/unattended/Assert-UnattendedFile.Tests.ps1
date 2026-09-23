BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestFileName ([String]'TEST_FILE_NAME.xml')

    Set-Variable -Option Constant TestValidContent ([String]"<?xml version=`"1.0`" encoding=`"utf-8`"?>
<!-- Version: 1.2.3 -->
<unattend xmlns=`"urn:schemas-microsoft-com:unattend`">
  <ScopeUrl>https://www.google.lv/search?q={searchTerms}</ScopeUrl>
  <File path=`"C:\Windows\Setup\FirstLogon.ps1`">'{0}' -f `$x</File>
</unattend>")
}

Describe 'Assert-UnattendedFile' {
    It 'Should accept a release answer file' {
        { Assert-UnattendedFile $TestFileName $TestValidContent } | Should -Not -Throw
    }

    It 'Should reject development-only content: <Marker>' -ForEach @(
        @{ Marker = '<Path>cmd.exe /c diskpart.exe /s X:\diskpart.txt</Path>' }
        @{ Marker = '<ImageInstall></ImageInstall>' }
        @{ Marker = '<UserAccounts></UserAccounts>' }
        @{ Marker = '<AutoLogon></AutoLogon>' }
        @{ Marker = '<File>Set-ItemProperty -Name AutoLogonCount -Value 0</File>' }
        @{ Marker = '<File>&amp; C:\Windows\Setup\VBoxGuestAdditions.ps1</File>' }
    ) {
        Set-Variable -Option Constant Content ([String]$TestValidContent.Replace('</unattend>', "$Marker</unattend>"))

        { Assert-UnattendedFile $TestFileName $Content } | Should -Throw "Development-only content * left in $TestFileName"
    }

    It 'Should reject unresolved placeholders' {
        Set-Variable -Option Constant Content ([String]$TestValidContent.Replace('</unattend>', '<File>{CONFIG_PERSONALISATION}</File></unattend>'))

        { Assert-UnattendedFile $TestFileName $Content } | Should -Throw "Unresolved placeholders in ${TestFileName}: {CONFIG_PERSONALISATION}"
    }

    It 'Should reject a file that is not well-formed XML' {
        Set-Variable -Option Constant Content ([String]"<!-- Version: 1.2.3 -->`n$TestValidContent")

        { Assert-UnattendedFile $TestFileName $Content } | Should -Throw "$TestFileName is not well-formed XML*"
    }
}
