BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    Set-Variable -Option Constant EmojiCodeDone '2705'
    Set-Variable -Option Constant EmojiCodeWarning '26A0'
    Set-Variable -Option Constant EmojiCodeError '274C'

    Set-Variable -Option Constant LogLevelInfo 'INFO'
    Set-Variable -Option Constant LogLevelWarning 'WARN'
    Set-Variable -Option Constant LogLevelError 'ERROR'

    Set-Variable -Option Constant TestDate 'TEST_DATE'
    Set-Variable -Option Constant TestEmoji 'TEST_EMOJI'

    Set-Variable -Option Constant TestMessage 'TEST_MESSAGE'
    Set-Variable -Option Constant FormattedMessage 'FORMATTED_MESSAGE'

    Set-Variable -Option Constant TestExceptionMessage 'TEST_EXCEPTION_MESSAGE'
    Set-Variable -Option Constant TestException @{Exception = @{Message = $TestExceptionMessage } }
}

Describe 'Get-Emoji' {
    It 'Returns <expected> (<code>)' -ForEach @(
        @{ Code = '2705'; Expected = '✅' }
        @{ Code = '26A0'; Expected = '⚠' }
        @{ Code = '274C'; Expected = '❌' }
    ) {
        Get-Emoji -Code $code | Should -Be $expected
    }
}

Describe 'Format-Message' {
    BeforeEach {
        Mock Get-Date { return $TestDate }
        Mock Get-Emoji { return $TestEmoji }
    }

    Context 'Log levels' {
        It 'Should format message correctly for info level' {
            Format-Message $LogLevelInfo $TestMessage | Should -Be "[$TestDate] $TestMessage"
            Should -Invoke -CommandName Get-Date -Times 1
            Should -Invoke -CommandName Get-Emoji -Times 0
        }

        It 'Should format message correctly for warning level' {
            Format-Message $LogLevelWarning $TestMessage | Should -Be "[$TestDate]$TestEmoji $TestMessage"
            Should -Invoke -CommandName Get-Date -Times 1
            Should -Invoke -CommandName Get-Emoji -Times 1 -ParameterFilter { $Code -eq $EmojiCodeWarning }
        }

        It 'Should format message correctly for error level' {
            Format-Message $LogLevelError $TestMessage | Should -Be "[$TestDate]$TestEmoji $TestMessage"
            Should -Invoke -CommandName Get-Date -Times 1
            Should -Invoke -CommandName Get-Emoji -Times 1 -ParameterFilter { $Code -eq $EmojiCodeError }
        }
    }

    Context 'Indent levels' {
        It 'Should format message correctly with emoji and indent level 0' {
            Format-Message $LogLevelWarning $TestMessage 0 | Should -Be "[$TestDate]$TestEmoji $TestMessage"
        }

        It 'Should format message correctly without emoji and indent level 0' {
            Format-Message $LogLevelInfo $TestMessage 0 | Should -Be "[$TestDate] $TestMessage"
        }

        It 'Should format message correctly with emoji and indent level 2' {
            Format-Message $LogLevelError $TestMessage 2 | Should -Be "[$TestDate]      $TestEmoji $TestMessage"
        }

        It 'Should format message correctly without emoji and indent level 2' {
            Format-Message $LogLevelInfo $TestMessage 2 | Should -Be "[$TestDate]       $TestMessage"
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

    It 'Should log message correctly for info level with indent level 1' {
        Write-LogInfo $TestMessage 1
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelInfo; $Message -eq $TestMessage; $IndentLevel -eq 1 }
        Should -Invoke -CommandName Write-Host -Times 1 -ParameterFilter { $Object -eq $FormattedMessage }
        Should -Invoke -CommandName Write-Warning -Times 0
        Should -Invoke -CommandName Write-Error -Times 0
    }

    It 'Should log message correctly for info level with default indent level' {
        Write-LogInfo $TestMessage
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelInfo; $Message -eq $TestMessage; $IndentLevel -eq 0 }
        Should -Invoke -CommandName Write-Host -Times 1 -ParameterFilter { $Object -eq $FormattedMessage }
        Should -Invoke -CommandName Write-Warning -Times 0
        Should -Invoke -CommandName Write-Error -Times 0
    }
}

Describe 'Write-LogWarning' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
    }

    It 'Should log message correctly for warning level with indent level 1' {
        Write-LogWarning $TestMessage 1
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelWarning; $Message -eq $TestMessage; $IndentLevel -eq 1 }
        Should -Invoke -CommandName Write-Host -Times 0
        Should -Invoke -CommandName Write-Warning -Times 1 -ParameterFilter { $Message -eq $FormattedMessage }
        Should -Invoke -CommandName Write-Error -Times 0
    }

    It 'Should log message correctly for warning level with default indent level' {
        Write-LogWarning $TestMessage
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelWarning; $Message -eq $TestMessage; $IndentLevel -eq 0 }
        Should -Invoke -CommandName Write-Host -Times 0
        Should -Invoke -CommandName Write-Warning -Times 1 -ParameterFilter { $Message -eq $FormattedMessage }
        Should -Invoke -CommandName Write-Error -Times 0
    }
}

Describe 'Write-LogError' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
    }

    It 'Should log message correctly for error level with indent level 1' {
        Write-LogError $TestMessage 1
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelError; $Message -eq $TestMessage; $IndentLevel -eq 1 }
        Should -Invoke -CommandName Write-Host -Times 0
        Should -Invoke -CommandName Write-Warning -Times 0
        Should -Invoke -CommandName Write-Error -Times 1 -ParameterFilter { $Message -eq $FormattedMessage }
    }

    It 'Should log message correctly for error level with default indent level' {
        Write-LogError $TestMessage
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelError; $Message -eq $TestMessage; $IndentLevel -eq 0 }
        Should -Invoke -CommandName Write-Host -Times 0
        Should -Invoke -CommandName Write-Warning -Times 0
        Should -Invoke -CommandName Write-Error -Times 1 -ParameterFilter { $Message -eq $FormattedMessage }
    }
}

Describe 'Write-LogException' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
    }

    It 'Should log exception correctly with indent level 1' {
        Write-LogException $TestException $TestMessage 1
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelError; $Message -eq "$($TestMessage): $TestExceptionMessage"; $IndentLevel -eq 1 }
        Should -Invoke -CommandName Write-Host -Times 0
        Should -Invoke -CommandName Write-Warning -Times 0
        Should -Invoke -CommandName Write-Error -Times 1 -ParameterFilter { $Message -eq $FormattedMessage }
    }

    It 'Should log exception correctly with default indent level' {
        Write-LogException $TestException $TestMessage
        Should -Invoke -CommandName Format-Message -Times 1 -ParameterFilter { $Level -eq $LogLevelError; $Message -eq "$($TestMessage): $TestExceptionMessage"; $IndentLevel -eq 0 }
        Should -Invoke -CommandName Write-Host -Times 0
        Should -Invoke -CommandName Write-Warning -Times 0
        Should -Invoke -CommandName Write-Error -Times 1 -ParameterFilter { $Message -eq $FormattedMessage }
    }
}

Describe 'Out-Status' {
    BeforeEach {
        Mock Write-LogInfo {}
    }

    It 'Should log status correctly with indent level 1' {
        Out-Status $TestMessage 1
        Should -Invoke -CommandName Write-LogInfo -Times 1 -ParameterFilter { $Message -eq "   > $TestMessage"; $IndentLevel -eq 1 }
    }

    It 'Should log status correctly with default indent level' {
        Out-Status $TestMessage
        Should -Invoke -CommandName Write-LogInfo -Times 1 -ParameterFilter { $Message -eq "   > $TestMessage"; $IndentLevel -eq 0 }
    }
}

Describe 'Out-Success' {
    BeforeEach {
        Mock Get-Emoji { return $TestEmoji }
        Mock Out-Status {}
    }

    It 'Should log success correctly with indent level 1' {
        Out-Success 1
        Should -Invoke -CommandName Out-Status -Times 1 -ParameterFilter { $Message -eq "Done $TestEmoji"; $IndentLevel -eq 1 }
    }

    It 'Should log success correctly with default indent level' {
        Out-Success
        Should -Invoke -CommandName Out-Status -Times 1 -ParameterFilter { $Message -eq "Done $TestEmoji"; $IndentLevel -eq 0 }
    }
}

Describe 'Out-Failure' {
    BeforeEach {
        Mock Get-Emoji { return $TestEmoji }
        Mock Out-Status {}
    }

    It 'Should log failure correctly with indent level 1' {
        Out-Failure 1
        Should -Invoke -CommandName Out-Status -Times 1 -ParameterFilter { $Message -eq "Done $TestEmoji"; $IndentLevel -eq 1 }
    }

    It 'Should log failure correctly with default indent level' {
        Out-Failure
        Should -Invoke -CommandName Out-Status -Times 1 -ParameterFilter { $Message -eq "Done $TestEmoji"; $IndentLevel -eq 0 }
    }
}
