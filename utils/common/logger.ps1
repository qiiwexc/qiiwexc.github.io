function Write-LogInfo {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )
    Write-Log 'INFO' $Message -IndentLevel $Level
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )
    Write-Log 'WARN' "$(Get-Emoji '26A0') $Message" -IndentLevel $Level
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )
    Write-Log 'ERROR' "$(Get-Emoji '274C') $Message" -IndentLevel $Level
}

function Write-Log {
    param(
        [String][Parameter(Position = 0, Mandatory)][ValidateSet('INFO', 'WARN', 'ERROR')]$Level,
        [String][Parameter(Position = 1, Mandatory)]$Message,
        [Int][Parameter(Position = 2)]$IndentLevel = 0
    )

    Set-Variable -Option Constant Indent $('   ' * $IndentLevel)
    Set-Variable -Option Constant Text "[$((Get-Date).ToString())]$Indent $Message"

    switch ($Level) {
        'INFO' {
            Write-Host $Text
        }
        'WARN' {
            Write-Warning $Text
        }
        'ERROR' {
            Write-Error $Text
        }
        Default {
            Write-Host $Text
        }
    }
}


function Out-Status {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Status,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Write-LogInfo "   > $Status" $Level
}


function Out-Success {
    param(
        [Int][Parameter(Position = 0)]$Level = 0
    )

    Out-Status "Done $(Get-Emoji '2705')" $Level
}

function Out-Failure {
    param(
        [Int][Parameter(Position = 0)]$Level = 0
    )

    Out-Status "Failed $(Get-Emoji '274C')" $Level
}


function Write-LogException {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Exception,
        [String][Parameter(Position = 1, Mandatory)]$Message,
        [Int][Parameter(Position = 2)]$Level = 0
    )

    Write-Log 'ERROR' "$($Message): $($Exception.Exception.Message)" -IndentLevel $Level
}

function Get-Emoji {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Code
    )

    Set-Variable -Option Constant Emoji ([Convert]::toInt32($Code, 16))

    return [Char]::ConvertFromUtf32($Emoji)
}
