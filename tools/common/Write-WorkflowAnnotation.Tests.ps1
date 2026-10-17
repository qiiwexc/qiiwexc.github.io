BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant TestMessage ([String]"Failed to check 'Ventoy' for updates")
}

Describe 'Write-WorkflowAnnotation' {
    BeforeAll {
        Mock Write-Host {}
    }

    It 'Should write a warning by default' {
        Write-WorkflowAnnotation $TestMessage

        Should -Invoke Write-Host -Exactly 1
        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -ceq "::warning::$TestMessage" }
    }

    It 'Should write an error' {
        Write-WorkflowAnnotation $TestMessage -Level error

        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -ceq "::error::$TestMessage" }
    }

    It 'Should keep a message of several lines in one annotation' {
        Write-WorkflowAnnotation "first`r`nsecond`nthird"

        Should -Invoke Write-Host -Exactly 1
        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -ceq '::warning::first%0D%0Asecond%0Athird' }
    }

    It 'Should not let a message start a command of its own' {
        Write-WorkflowAnnotation "gh failed`n::error::injected"

        Should -Invoke Write-Host -Exactly 1
        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -ceq '::warning::gh failed%0A::error::injected' }
    }

    It 'Should escape a percent sign, so that it is never read as a line break' {
        Write-WorkflowAnnotation 'Downloaded 100%0A'

        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -ceq '::warning::Downloaded 100%250A' }
    }

    It 'Should reject a level that is not an annotation' {
        { Write-WorkflowAnnotation $TestMessage -Level 'debug' } | Should -Throw

        Should -Invoke Write-Host -Exactly 0
    }
}
