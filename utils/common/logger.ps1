Add-Type -TypeDefinition @'
    public enum LogLevel {
        INFO,
        WARN,
        ERROR
    }
'@

function Write-LogInfo {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Write-Log ([LogLevel]::INFO) $Message -IndentLevel $Level
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Write-Log ([LogLevel]::WARN) "$(Get-Emoji '26A0') $Message" -IndentLevel $Level
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Write-Log ([LogLevel]::ERROR) "$(Get-Emoji '274C') $Message" -IndentLevel $Level
}

function Write-Log {
    param(
        [LogLevel][Parameter(Position = 0, Mandatory)]$Level,
        [String][Parameter(Position = 1, Mandatory)]$Message,
        [Int][Parameter(Position = 2)]$IndentLevel = 0
    )

    Set-Variable -Option Constant Indent ([String]$('   ' * $IndentLevel))
    Set-Variable -Option Constant Date ([String]$((Get-Date).ToString()))
    Set-Variable -Option Constant Text ([String]"[$Date]$Indent $Message")

    switch ($Level) {
        ([LogLevel]::INFO) {
            Write-Host $Text
        }
        ([LogLevel]::WARN) {
            Write-Warning $Text
        }
        ([LogLevel]::ERROR) {
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

    Write-Log ([LogLevel]::ERROR) "$($Message): $($Exception.Exception.Message)" -IndentLevel $Level
}

function Get-Emoji {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Code
    )

    Set-Variable -Option Constant Emoji ([Convert]::toInt32($Code, 16))

    return [Char]::ConvertFromUtf32($Emoji)
}
