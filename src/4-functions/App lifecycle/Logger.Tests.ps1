BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    . '.\src\4-functions\Common\types.ps1'

    Add-Type -AssemblyName System.Windows.Forms

    Set-Variable -Option Constant EmojiCodeDone ([String]'2705')
    Set-Variable -Option Constant EmojiCodeWarning ([String]'26A0')
    Set-Variable -Option Constant EmojiCodeError ([String]'274C')

    Set-Variable -Option Constant LogLevelDebug ([String]'DEBUG')
    Set-Variable -Option Constant LogLevelInfo ([String]'INFO')
    Set-Variable -Option Constant LogLevelWarning ([String]'WARN')
    Set-Variable -Option Constant LogLevelError ([String]'ERROR')

    Set-Variable -Option Constant TestDate ([String]'TEST_DATE')
    Set-Variable -Option Constant TestEmoji ([String]'TEST_EMOJI')

    Set-Variable -Option Constant TestMessage ([String]'TEST_MESSAGE')
    Set-Variable -Option Constant FormattedMessage ([String]'FORMATTED_MESSAGE')
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

        Set-Variable -Option Constant ACTIVITIES ([Collections.Stack]@())
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

        It 'Should format message correctly with a running activity' {
            $ACTIVITIES.Push('Activity 1')
            Format-Message $LogLevelInfo $TestMessage | Should -BeExactly "[$TestDate]    $TestMessage"
        }

        It 'Should format message correctly with 2 running activities' {
            $ACTIVITIES.Push('Activity 2')
            Format-Message $LogLevelInfo $TestMessage | Should -BeExactly "[$TestDate]       $TestMessage"
        }
    }
}

Describe 'Write-FormLog' {
    BeforeAll {
        function AppendText {}
        function ScrollToCaret {}
    }

    BeforeEach {
        $LOG = New-MockObject -Type Windows.Forms.RichTextBox -Properties @{
            TextLength     = 123
            SelectionStart = 0
            SelectionColor = ''
        } -Methods @{
            AppendText    = { AppendText }
            ScrollToCaret = { ScrollToCaret }
        }

        Mock AppendText {
            $LOG.SelectionColor | Should -BeExactly $Expected
        }
        Mock ScrollToCaret {}
    }

    Context 'Log levels' {
        It 'Should log message correctly for <LogLevel> level' -ForEach @(
            @{ LogLevel = 'INFO'; Expected = 'black' }
            @{ LogLevel = 'WARN'; Expected = 'blue' }
            @{ LogLevel = 'ERROR'; Expected = 'red' }
        ) {
            Write-FormLog $LogLevel $TestMessage

            $LOG.SelectionStart | Should -BeExactly 123
            $LOG.SelectionColor | Should -BeExactly 'black'

            Should -Invoke AppendText -Exactly 1
            Should -Invoke AppendText -Exactly 1 -ParameterFilter { $TestMessage }
            Should -Invoke ScrollToCaret -Exactly 1
        }
    }

    Context 'New line' {
        It 'Should log message correctly with new line' {
            Mock AppendText {}

            Write-FormLog $LogLevelInfo $TestMessage -NoNewLine

            Should -Invoke AppendText -Exactly 1
            Should -Invoke AppendText -Exactly 1 -ParameterFilter { "`n$TestMessage" }
        }
    }
}

Describe 'Write-LogDebug' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
        Mock Write-FormLog {}
    }

    It 'Should log message correctly for debug level with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $Null; Expected = 0 }
    ) {
        Write-LogDebug $TestMessage $Level

        Should -Invoke Format-Message -Exactly 1
        Should -Invoke Format-Message -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelDebug -and
            $Message -eq $TestMessage -and
            $IndentLevel -eq $Expected
        }
        Should -Invoke Write-Host -Exactly 1
        Should -Invoke Write-Host -Exactly 1 -ParameterFilter { $Object -eq $FormattedMessage }
        Should -Invoke Write-Warning -Exactly 0
        Should -Invoke Write-Error -Exactly 0
        Should -Invoke Write-FormLog -Exactly 0
    }
}

Describe 'Write-LogInfo' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
        Mock Write-FormLog {}
    }

    It 'Should log message correctly for info level with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $Null; Expected = 0 }
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
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelInfo -and
            $Message -eq $FormattedMessage
        }
    }
}

Describe 'Write-LogWarning' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
        Mock Write-FormLog {}
    }

    It 'Should log message correctly for warning level with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $Null; Expected = 0 }
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
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelWarning -and
            $Message -eq $FormattedMessage
        }
    }
}

Describe 'Write-LogError' {
    BeforeEach {
        Mock Format-Message { return $FormattedMessage }
        Mock Write-Host {}
        Mock Write-Warning {}
        Mock Write-Error {}
        Mock Write-FormLog {}
    }

    It 'Should log message correctly for error level with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $Null; Expected = 0 }
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
        Should -Invoke Write-FormLog -Exactly 1
        Should -Invoke Write-FormLog -Exactly 1 -ParameterFilter {
            $Level -eq $LogLevelError -and
            $Message -eq $FormattedMessage
        }
    }
}

Describe 'Out-Status' {
    BeforeEach {
        Mock Write-LogInfo {}
    }

    It 'Should log status correctly with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $Null; Expected = 0 }
    ) {
        Out-Status $TestMessage $Level

        Should -Invoke Write-LogInfo -Exactly 1
        Should -Invoke Write-LogInfo -Exactly 1 -ParameterFilter {
            $Message -eq " > $TestMessage" -and
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
        @{ Level = $Null; Expected = 0 }
    ) {
        Out-Success $Level

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Out-Status -Exactly 1 -ParameterFilter {
            $Level -eq $Expected -and
            $Status -eq "Done $TestEmoji"
        }
    }
}

Describe 'Out-Failure' {
    BeforeEach {
        Mock Get-Emoji { return $TestEmoji }
        Mock Out-Status {}
    }

    It 'Should log failure correctly with indent level <Level>' -ForEach @(
        @{ Level = 1; Expected = 1 }
        @{ Level = $Null; Expected = 0 }
    ) {
        Out-Failure $TestMessage $Level

        Should -Invoke Out-Status -Exactly 1
        Should -Invoke Out-Status -Exactly 1 -ParameterFilter {
            $Level -eq $Expected -and
            $Status -eq "$TestEmoji $TestMessage"
        }
    }
}
