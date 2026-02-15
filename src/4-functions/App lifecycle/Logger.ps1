function Write-LogDebug {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::DEBUG) $Message -IndentLevel $Level))
    Write-Host $FormattedMessage
}

function Write-LogInfo {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::INFO) $Message -IndentLevel $Level))
    Write-Host $FormattedMessage
    Write-FormLog ([LogLevel]::INFO) $FormattedMessage
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::WARN) $Message -IndentLevel $Level))
    Write-Warning $FormattedMessage
    Write-FormLog ([LogLevel]::WARN) $FormattedMessage
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([LogLevel]::ERROR) $Message -IndentLevel $Level))
    Write-Error $FormattedMessage
    Write-FormLog ([LogLevel]::ERROR) $FormattedMessage
}

function Out-Status {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Status,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Write-LogInfo " > $Status" $Level
}


function Out-Success {
    param(
        [Int][Parameter(Position = 0)]$Level = 0
    )

    Out-Status "Done $(Get-Emoji '2705')" $Level
}

function Out-Failure {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Out-Status "$(Get-Emoji '274C') $Message" $Level
}


function Get-Emoji {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Code
    )

    Set-Variable -Option Constant Emoji ([Convert]::ToInt32($Code, 16))

    return [Char]::ConvertFromUtf32($Emoji)
}


function Format-Message {
    param(
        [LogLevel][Parameter(Position = 0, Mandatory)]$Level,
        [String][Parameter(Position = 1, Mandatory)]$Message,
        [Int][Parameter(Position = 2)]$IndentLevel = 0
    )

    switch ($Level) {
        ([LogLevel]::WARN) {
            Set-Variable -Option Constant Emoji (Get-Emoji '26A0')
        }
        ([LogLevel]::ERROR) {
            Set-Variable -Option Constant Emoji (Get-Emoji '274C')
        }
        Default {}
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
    param(
        [LogLevel][Parameter(Position = 0, Mandatory)]$Level,
        [String][Parameter(Position = 1, Mandatory)]$Message,
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

    if ($FORM.Dispatcher.CheckAccess()) {
        $LogAction.Invoke()
        [void]$FORM.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, [Action] {})
    } else {
        [void]$FORM.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Render, $LogAction)
    }
}
