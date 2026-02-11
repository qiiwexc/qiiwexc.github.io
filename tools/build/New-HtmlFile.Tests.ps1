BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\tools\common\types.ps1'
    . '.\tools\common\Progressbar.ps1'
    . '.\tools\common\Read-TextFile.ps1'
    . '.\tools\common\Write-TextFile.ps1'

    Set-Variable -Option Constant TestException ([String]'TEST_EXCEPTION')

    Set-Variable -Option Constant TestTemplatesPath ([String]'TEST_TEMPLATES_PATH')
    Set-Variable -Option Constant TestBuildPath ([String]'TEST_BUILD_PATH')
    Set-Variable -Option Constant TestConfig ([Config[]]@(
            @{key = 'KEY_1'; value = 'VALUE_1' },
            @{key = 'KEY_2'; value = 'VALUE_2' },
            @{key = 'URL_STYLESHEET_WEB'; value = 'https://bit.ly/stylesheet_web' }
        ))

    Set-Variable -Option Constant TestTemplateFilePath ([String]"$TestTemplatesPath\home.html")
    Set-Variable -Option Constant TestOutFilePath ([String]"$TestBuildPath\index.html")

    Set-Variable -Option Constant TestTemplateContent ([String]'<html>{KEY_1} ../d/stylesheet.css {KEY_2}</html>')
    Set-Variable -Option Constant TestHtmlContent ([String]'<html>VALUE_1 https://bit.ly/stylesheet_web VALUE_2</html>')
}

Describe 'New-HtmlFile' {
    BeforeEach {
        Mock New-Activity {}
        Mock Read-TextFile { return $TestTemplateContent }
        Mock Write-TextFile {}
        Mock Write-ActivityCompleted {}
    }

    It 'Should create new HTML file from template' {
        New-HtmlFile $TestTemplatesPath $TestBuildPath $TestConfig

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1 -ParameterFilter { $Path -eq $TestTemplateFilePath }
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Path -eq $TestOutFilePath -and
            $Content -eq $TestHtmlContent -and
            $NoNewline -eq $True
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle Read-TextFile failure' {
        Mock Read-TextFile { throw $TestException }

        { New-HtmlFile $TestTemplatesPath $TestBuildPath $TestConfig } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 0
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle Write-TextFile failure' {
        Mock Write-TextFile { throw $TestException }

        { New-HtmlFile $TestTemplatesPath $TestBuildPath $TestConfig } | Should -Throw $TestException

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-ActivityCompleted -Exactly 0
    }

    It 'Should handle template with no placeholders' {
        Mock Read-TextFile { return '<html>Static content ../d/stylesheet.css</html>' }

        New-HtmlFile $TestTemplatesPath $TestBuildPath $TestConfig

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Content -eq '<html>Static content https://bit.ly/stylesheet_web</html>'
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should handle empty template content' {
        Mock Read-TextFile { return '' }

        New-HtmlFile $TestTemplatesPath $TestBuildPath $TestConfig

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            [String]::IsNullOrEmpty($Content)
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }

    It 'Should leave unknown placeholders unchanged' {
        Mock Read-TextFile { return '<html>{UNKNOWN_KEY} ../d/stylesheet.css</html>' }

        New-HtmlFile $TestTemplatesPath $TestBuildPath $TestConfig

        Should -Invoke New-Activity -Exactly 1
        Should -Invoke Read-TextFile -Exactly 1
        Should -Invoke Write-TextFile -Exactly 1 -ParameterFilter {
            $Content -eq '<html>{UNKNOWN_KEY} https://bit.ly/stylesheet_web</html>'
        }
        Should -Invoke Write-ActivityCompleted -Exactly 1
    }
}
