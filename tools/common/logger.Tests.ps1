BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant EmojiCodeDone ([String]'2705')
    Set-Variable -Option Constant EmojiCodeWarning ([String]'26A0')
    Set-Variable -Option Constant EmojiCodeError ([String]'274C')

    Set-Variable -Option Constant LogLevelInfo ([String]'INFO')
    Set-Variable -Option Constant LogLevelWarning ([String]'WARN')
    Set-Variable -Option Constant LogLevelError ([String]'ERROR')

    Set-Variable -Option Constant TestDate ([String]'TEST_DATE')
    Set-Variable -Option Constant TestEmoji ([String]'TEST_EMOJI')

    Set-Variable -Option Constant TestMessage ([String]'TEST_MESSAGE')
    Set-Variable -Option Constant FormattedMessage ([String]'FORMATTED_MESSAGE')

    Set-Variable -Option Constant TestExceptionMessage ([String]'TEST_EXCEPTION_MESSAGE')
    Set-Variable -Option Constant TestException (
        [Object]@{Exception = @{Message = $TestExceptionMessage } }
    )
}

Describe 'Get-Emoji' {
    It 'Returns <Expected> (<Code>)' -ForEach @(
        @{ Code = '2705'; Expected = '✅' }
        @{ Code = '26A0'; Expected = '⚠' }
        @{ Code = '274C'; Expected = '❌' }
    ) {
        Get-Emoji -Code $Code | Should -BeExactly $Expected
    }
}

Describe 'Format-Message' {
    BeforeAll {
        function ToString {}
    }

    BeforeEach {
        Mock ToString { return $TestDate }
        Mock Get-Date { return ToString }
        Mock Get-Emoji { return $TestEmoji }
    }

    Context 'Log levels' {
        It 'Should format message correctly for info level' {
            Format-Message $LogLevelInfo $TestMessage | Should -BeExactly "[$TestDate] $TestMessage"

            Should -Invoke Get-Date -Exactly 1
            Should -Invoke ToString -Exactly 1
            Should -Invoke Get-Emoji -Exactly 0
        }

        It 'Should format message correctly for warning level' {
            Format-Message $LogLevelWarning $TestMessage | Should -BeExactly "[$TestDate]$TestEmoji $TestMessage"

            Should -Invoke Get-Date -Exactly 1
            Should -Invoke ToString -Exactly 1
            Should -Invoke Get-Emoji -Exactly 1
            Should -Invoke Get-Emoji -Exactly 1 -ParameterFilter { $Code -eq $EmojiCodeWarning }
        }

        It 'Should format message correctly for error level' {
            Format-Message $LogLevelError $TestMessage | Should -BeExactly "[$TestDate]$TestEmoji $TestMessage"

            Should -Invoke Get-Date -Exactly 1
            Should -Invoke ToString -Exactly 1
            Should -Invoke Get-Emoji -Exactly 1
            Should -Invoke Get-Emoji -Exactly 1 -ParameterFilter { $Code -eq $EmojiCodeError }
        }
    }

    Context 'Indent levels' {
        It 'Should format message correctly with emoji and indent level 0' {
            Format-Message $LogLevelWarning $TestMessage 0 | Should -BeExactly "[$TestDate]$TestEmoji $TestMessage"
        }

        It 'Should format message correctly without emoji and indent level 0' {
            Format-Message $LogLevelInfo $TestMessage 0 | Should -BeExactly "[$TestDate] $TestMessage"
        }

        It 'Should format message correctly with emoji and indent level 2' {
            Format-Message $LogLevelError $TestMessage 2 | Should -BeExactly "[$TestDate]      $TestEmoji $TestMessage"
        }

        It 'Should format message correctly without emoji and indent level 2' {
            Format-Message $LogLevelInfo $TestMessage 2 | Should -BeExactly "[$TestDate]       $TestMessage"
        }
    }
}

Describe 'Write-LogInfo' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
    }

    It 'Should log message correctly for info level with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $null; Expected = 0 }
    ) {
        Write-LogInfo $TestMessage $Level

        Should -Invoke Format-Message -Exactly 1
        Should -Invoke Format-Message -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelInfo -and
            $Message -eq $TestMessage -and
            $IndentLevel -eq $Expected
        }
        Should -Invoke Write-Host -Exactly 1
        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -eq $FormattedMessage }
        Should -Invoke Write-Warning -Exactly 0
        Should -Invoke Write-Error -Exactly 0
    }
}

Describe 'Write-LogWarning' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
    }

    It 'Should log message correctly for warning level with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $null; Expected = 0 }
    ) {
        Write-LogWarning $TestMessage $Level

        Should -Invoke Format-Message -Exactly 1
        Should -Invoke Format-Message -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelWarning -and
            $Message -eq $TestMessage -and
            $IndentLevel -eq $Expected
        }
        Should -Invoke Write-Host -Exactly 0
        Should -Invoke Write-Warning -Exactly 1
        Should -Invoke Write-Warning -Exactly 1 -ParameterFilter { $Message -eq $FormattedMessage }
        Should -Invoke Write-Error -Exactly 0
    }
}

Describe 'Write-LogError' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
    }

    It 'Should log message correctly for error level with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $null; Expected = 0 }
    ) {
        Write-LogError $TestMessage $Level

        Should -Invoke Format-Message -Exactly 1
        Should -Invoke Format-Message -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelError -and
            $Message -eq $TestMessage -and
            $IndentLevel -eq $Expected
        }
        Should -Invoke Write-Host -Exactly 0
        Should -Invoke Write-Warning -Exactly 0
        Should -Invoke Write-Error -Exactly 1
        Should -Invoke Write-Error -Exactly 1 -ParameterFilter { $Message -eq $FormattedMessage }
    }
}

Describe 'Write-LogException' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
    }

    It 'Should log exception correctly with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $null; Expected = 0 }
    ) {
        Write-LogException $TestException $TestMessage $Level

        Should -Invoke Format-Message -Exactly 1
        Should -Invoke Format-Message -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelError -and
            $Message -eq "$($TestMessage): $TestExceptionMessage" -and
            $IndentLevel -eq $Expected
        }
        Should -Invoke Write-Host -Exactly 0
        Should -Invoke Write-Warning -Exactly 0
        Should -Invoke Write-Error -Exactly 1
        Should -Invoke Write-Error -Exactly 1 -ParameterFilter { $Message -eq $FormattedMessage }
    }
}

Describe 'Out-Status' {
    BeforeEach {
        Mock Write-LogInfo {}
    }

    It 'Should log status correctly with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $null; Expected = 0 }
    ) {
        Out-Status $TestMessage $Level

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter {
            $Message -eq "   > $TestMessage" -and
            $Level -eq $Expected
        }
    }
}

Describe 'Out-Success' {
    BeforeEach {
        Mock Get-Emoji { return $TestEmoji }
        Mock Out-Status {}
    }

    It 'Should log success correctly with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $null; Expected = 0 }
    ) {
        Out-Success $Level

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Out-Status -Exactly 1 -ParameterFilter { $Level -eq $Expected }
    }
}

Describe 'Out-Failure' {
    BeforeEach {
        Mock Get-Emoji { return $TestEmoji }
        Mock Out-Status {}
    }

    It 'Should log failure correctly with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $null; Expected = 0 }
    ) {
        Out-Failure $Level

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Out-Status -Exactly 1 -ParameterFilter { $Level -eq $Expected }
    }
}
