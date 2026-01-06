BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Write-File.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestTemplatesPath ([String]'TEST_TEMPLATES_PATH')
    Set-Variable -Option Constant TestBaseFilePath ([String]'TEST_BASE_FILE_PATH')

    Set-Variable -Option Constant TestTemplateFileFilePath ([String]"$TestTemplatesPath\autounattend.xml")

    Set-Variable -Option Constant TestTemplateFileContent ([String]"Windows Registry Editor Version 5.00`r`n`r`n<ExtractScript><HideOnlineAccountScreens>false</HideOnlineAccountScreens></ExtractScript>`n`t`t<File path=`"C:\Windows\Setup\Scripts\RemoveFeatures.ps1`">`n`$selectors = @(`n`t'Test1'`n`t'Test2'`n);`n`t`t</File>`n`t`t<File path=`"C:\Windows\Setup\Scripts\RemovePackages.ps1`">`n`$selectors = @(`n`t'Test1'`n`t'Test2'`n);`n`t`t</File>`n`t`t<File path=`"C:\Windows\Setup\Scripts\RemoveCapabilities.ps1`">`n`$selectors = @(`n`t'Test1';`n`t'Test2';`n);`n`t`t</File>`n")
}

Describe 'New-UnattendedBase' {
    BeforeEach {
        Mock Write-File {}
        Mock Get-Content { return $TestTemplateFileContent }
    }

    It 'Should create unattended base file successfully' {
        Set-Variable -Option Constant Result (New-UnattendedBase $TestTemplatesPath $TestBaseFilePath)

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestTemplateFileFilePath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Write-File -Exactly 1
        Should -Invoke Write-File -Exactly 1 -ParameterFilter {
            $Path -eq $TestBaseFilePath -and
            $Content -match "^<!-- Version: {VERSION} -->`n" -and
            $Content -notmatch "`t" -and
            $Content -notmatch "Windows Registry Editor Version 5\.00`r`n`r`n" -and
            $Content -notmatch 'C:\\Windows\\Setup\\Scripts\\' -and
            $Content -match 'C:\\Windows\\Setup\\' -and
            $Content -notmatch '<HideOnlineAccountScreens>false</HideOnlineAccountScreens>' -and
            $Content -match '<HideOnlineAccountScreens>true</HideOnlineAccountScreens>' -and
            $Content -notmatch 'C:\\Windows\\Setup\\Scripts\\' -and
            $Content -match 'C:\\Windows\\Setup\\' -and
            $Content -notmatch 'Test1' -and
            $Content -notmatch 'Test2' -and
            $Content -match '\$selectors = @\({FEATURE_REMOVAL_LIST}\);' -and
            $Content -match '\$selectors = @\({CAPABILITY_REMOVAL_LIST}\);' -and
            $Content -match 'C:\\Windows\\Setup\\AppAssociations.xml' -and
            $Content -match '{CONFIG_APP_ASSOCIATIONS}'
        }
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { New-UnattendedBase $TestTemplatesPath $TestBaseFilePath } | Should -Throw

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Write-File -Exactly 0
    }

    It 'Should handle Write-File failure' {
        Mock Write-File { throw $TestException }

        { New-UnattendedBase $TestTemplatesPath $TestBaseFilePath } | Should -Throw

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Write-File -Exactly 1
    }
}
