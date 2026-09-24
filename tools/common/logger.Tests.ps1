BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # Declared by the progress bar, which the logger reads for the indentation
    Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@())

    Set-Variable -Option Constant TestMessage ([String]'TEST_MESSAGE')
}

# The logger itself is the app's, and its tests are next to it in src; these cover what the build replaces
Describe 'logger' {
    BeforeAll {
        Mock Write-Host {}
        Mock Write-Warning {}
    }

    It 'Should log to the console only' {
        Write-LogInfo $TestMessage

        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -like "*$TestMessage" }
    }

    It 'Should log warnings to the warning stream' {
        Write-LogWarning $TestMessage

        Should -Invoke Write-Warning -Exactly 1 -ParameterFilter { $Message -like "*$TestMessage" }
    }

    It 'Should write nothing to a window' {
        Write-FormLog ([LogLevel]::INFO) $TestMessage | Should -BeNullOrEmpty
    }
}
