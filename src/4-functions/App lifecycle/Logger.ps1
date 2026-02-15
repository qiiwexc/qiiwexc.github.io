function Write-LogDebug {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::DEBUG) $Message -IndentLevel $Level))
    Write-Host $FormattedMessage
}

function Write-LogInfo {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::INFO) $Message -IndentLevel $Level))
    Write-Host $FormattedMessage
    Write-FormLog ([LogLevel]::INFO) $FormattedMessage
}

function Write-LogWarning {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::WARN) $Message -IndentLevel $Level))
    Write-Warning $FormattedMessage
    Write-FormLog ([LogLevel]::WARN) $FormattedMessage
}

function Write-LogError {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::ERROR) $Message -IndentLevel $Level))
    Write-Error $FormattedMessage
    Write-FormLog ([LogLevel]::ERROR) $FormattedMessage
}

function Out-Status {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Status,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Write-LogInfo " > $Status" $Level
}


function Out-Success {
    param(
        [Parameter(Position = 0)][Int]$Level = 0
    )

    Out-Status "Done $(ConvertTo-Emoji '2705')" $Level
}

function Out-Failure {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Out-Status "$(ConvertTo-Emoji '274C') $Message" $Level
}


function ConvertTo-Emoji {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Code
    )

    Set-Variable -Option Constant Emoji ([Convert]::ToInt32($Code, 16))

    return [Char]::ConvertFromUtf32($Emoji)
}


function Format-Message {
    param(
        [Parameter(Position = 0, Mandatory)][LogLevel]$Level,
        [Parameter(Position = 1, Mandatory)][String]$Message,
        [Parameter(Position = 2)][Int]$IndentLevel = 0
    )

    [String]$Emoji = ''

    switch ($Level) {
        ([LogLevel]::WARN) {
            $Emoji = ConvertTo-Emoji '26A0'
        }
        ([LogLevel]::ERROR) {
            $Emoji = ConvertTo-Emoji '274C'
        }
    }

    if (-not $ACTIVITIES -or $ACTIVITIES.Count -le 0) {
        Set-Variable -Option Constant Indent ([Int]$IndentLevel)
    } else {
        Set-Variable -Option Constant Indent ([Int]($ACTIVITIES.Count + $IndentLevel))
    }

    Set-Variable -Option Constant IndentSpaces ([String]$('   ' * $Indent))
    Set-Variable -Option Constant Date ([String]$((Get-Date).ToString()))

    return ([String]"[$Date]$IndentSpaces$Emoji $Message")
}


function Write-FormLog {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    param(
        [Parameter(Position = 0, Mandatory)][LogLevel]$Level,
        [Parameter(Position = 1, Mandatory)][String]$Message,
        [Switch]$NoNewLine
    )

    Set-Variable -Option Constant LogAction ([Action] {
            Set-Variable -Option Constant Run ([Windows.Documents.Run](New-Object Windows.Documents.Run))

            switch ($Level) {
                ([LogLevel]::WARN) {
                    $Run.Foreground = $FORM.Resources['LogWarnColor']
                }
                ([LogLevel]::ERROR) {
                    $Run.Foreground = $FORM.Resources['LogErrorColor']
                }
                Default {
                    $Run.Foreground = $FORM.Resources['LogFgColor']
                }
            }

            if ($NoNewLine) {
                $Run.Text = $Message
            } else {
                $Run.Text = "`n$Message"
            }

            $LOG.Inlines.Add($Run)
            $LOG_BOX.ScrollToEnd()
        })

    Invoke-OnDispatcher $LogAction -FlushRender
}
