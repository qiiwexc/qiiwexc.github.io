BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\logger.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestTemplatesPath ([String]'TEST_TEMPLATES_PATH')
    Set-Variable -Option Constant TestConfig ([PSCustomObject[]]@(@{key = 'KEY_1'; value = 'VALUE_1' }, @{key = 'KEY_2'; value = 'VALUE_2' }))

    Set-Variable -Option Constant TestTemplateFilePath ([String]"$TestTemplatesPath\home.html")
    Set-Variable -Option Constant TestOutFilePath ([String]'.\index.html')

    Set-Variable -Option Constant TestTemplateContent ([String]'<html>{KEY_1} ../d/stylesheet.css {KEY_2}</html>')
    Set-Variable -Option Constant TestHtmlContent ([String]'<html>VALUE_1 https://bit.ly/stylesheet_web VALUE_2</html>')
}

Describe 'New-HtmlFile' {
    BeforeEach {
        Mock Write-LogInfo {}
        Mock Get-Content { return $TestTemplateContent }
        Mock Set-Content {}
        Mock Out-Success {}
    }

    It 'Should create new HTML file from template' {
        New-HtmlFile $TestTemplatesPath $TestConfig

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Get-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestTemplateFilePath -and
            $Raw -eq $True -and
            $Encoding -eq 'UTF8'
        }
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1 -ParameterFilter {
            $Path -eq $TestOutFilePath -and
            $Value -eq $TestHtmlContent -and
            $NoNewline -eq $True
        }
        Should -Invoke Out-Success -Exactly 1
    }

    It 'Should handle Get-Content failure' {
        Mock Get-Content { throw $TestException }

        { New-HtmlFile $TestTemplatesPath $TestConfig } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 0
        Should -Invoke Out-Success -Exactly 0
    }

    It 'Should handle Set-Content failure' {
        Mock Set-Content { throw $TestException }

        { New-HtmlFile $TestTemplatesPath $TestConfig } | Should -Throw $TestException

        Should -Invoke Get-Content -Exactly 1
        Should -Invoke Set-Content -Exactly 1
        Should -Invoke Out-Success -Exactly 0
    }
}
