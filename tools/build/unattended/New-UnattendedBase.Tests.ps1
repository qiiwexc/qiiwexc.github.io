BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\Read-TextFile.ps1'
    . '.\tools\common\Write-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestTemplatesPath ([String]'TEST_TEMPLATES_PATH')
    Set-Variable -Option Constant TestBaseFilePath ([String]'TEST_BASE_FILE_PATH')

    Set-Variable -Option Constant TestTemplateFileFilePath ([String]"$TestTemplatesPath\autounattend.xml")

    Set-Variable -Option Constant TestTemplateFileContent ([String]"Windows Registry Editor Version 5.00`n`n<ExtractScript><HideOnlineAccountScreens>false</HideOnlineAccountScreens></ExtractScript>`n`t`t<File path=`"C:\Windows\Setup\Scripts\RemovePackages.ps1`">`n`$selectors = @(`n`t'Test1'`n`t'Test2'`n);`n`t`t</File>`n")
}

Describe 'New-UnattendedBase' {
    BeforeEach {
        Mock Read-TextFile { return $TestTemplateFileContent }
        Mock Write-TextFile {}
    }

    It 'Should create unattended base file' {
        Set-Variable -Option Constant Result (New-UnattendedBase $TestTemplatesPath $TestBaseFilePath)

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestTemplateFileFilePath }
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestBaseFilePath -and
            $Content -match "^<!-- Version: {VERSION} -->`n" -and
            $Content -notmatch "`t" -and
            $Content -notmatch "Windows Registry Editor Version 5\.00`r`n`r`n" -and
            $Content -notmatch '<HideOnlineAccountScreens>false</HideOnlineAccountScreens>' -and
            $Content -match '<HideOnlineAccountScreens>true</HideOnlineAccountScreens>' -and
            $Content -notmatch 'C:\\Windows\\Setup\\Scripts\\' -and
            $Content -match 'C:\\Windows\\Setup\\' -and
            $Content -notmatch 'Test1' -and
            $Content -notmatch 'Test2' -and
            $Content -match 'C:\\Windows\\Setup\\AppAssociations.xml' -and
            $Content -match '{CONFIG_APP_ASSOCIATIONS}'
        }
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { New-UnattendedBase $TestTemplatesPath $TestBaseFilePath } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 0
    }

    It 'Should handle Write-TextFile failure' {
        Mock Write-TextFile { throw $TestException }

        { New-UnattendedBase $TestTemplatesPath $TestBaseFilePath } | Should -Throw $TestException

        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
    }
}
