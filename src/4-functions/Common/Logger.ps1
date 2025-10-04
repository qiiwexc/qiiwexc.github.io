function Write-LogDebug {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'DEBUG' $Message
}

function Write-LogInfo {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'INFO' $Message
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'WARN' "$(Get-Emoji '26A0') $Message"
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'ERROR' "$(Get-Emoji '274C') $Message"
}

function Write-Log {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"

    $LOG.SelectionStart = $LOG.TextLength

    switch ($Level) {
        'DEBUG' {
            $LOG.SelectionColor = 'black'
            Write-Host -NoNewline "$Text`n"
        }
        'INFO' {
            $LOG.SelectionColor = 'black'
            Write-Host -NoNewline "$Text`n"
        }
        'WARN' {
            $LOG.SelectionColor = 'blue'
            Write-Warning $Text
        }
        'ERROR' {
            $LOG.SelectionColor = 'red'
            Write-Error $Text
        }
        Default {
            $LOG.SelectionColor = 'black'
            Write-Host -NoNewline "$Text`n"
        }
    }

    if ($Level -ne 'DEBUG') {
        $LOG.AppendText("$Text`n")
        $LOG.SelectionColor = 'black'
        $LOG.ScrollToCaret()
    }
}


function Out-Status {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Status
    )

    Write-LogInfo "   > $Status"
}


function Out-Success {
    Out-Status "Done $(Get-Emoji '2705')"
}

function Out-Failure {
    Out-Status "Failed $(Get-Emoji '274C')"
}


function Write-ExceptionLog {
    param(
        [Object][Parameter(Position = 0, Mandatory = $True)]$Exception,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Write-Log 'ERROR' "$($Message): $($Exception.Exception.Message)"
}

function Get-Emoji {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Code
    )

    Set-Variable -Option Constant Emoji ([System.Convert]::toInt32($Code, 16))

    return [System.Char]::ConvertFromUtf32($Emoji)
}
