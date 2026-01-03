Add-Type -TypeDefinition @'
    public enum DevLogLevel {
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

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([DevLogLevel]::INFO) $Message -IndentLevel $Level))
    Write-Host $FormattedMessage
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([DevLogLevel]::WARN) $Message -IndentLevel $Level))
    Write-Warning $FormattedMessage
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([DevLogLevel]::ERROR) $Message -IndentLevel $Level))
    Write-Error $FormattedMessage
}

function Write-LogException {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Exception,
        [String][Parameter(Position = 1, Mandatory)]$Message,
        [Int][Parameter(Position = 2)]$Level = 0
    )

    Set-Variable -Option Constant FormattedMessage ([String](Format-Message ([DevLogLevel]::ERROR) "$($Message): $($Exception.Exception.Message)" -IndentLevel $Level))
    Write-Error $FormattedMessage
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


function Get-Emoji {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Code
    )

    Set-Variable -Option Constant Emoji ([Convert]::toInt32($Code, 16))

    return [Char]::ConvertFromUtf32($Emoji)
}


function Format-Message {
    param(
        [DevLogLevel][Parameter(Position = 0, Mandatory)]$Level,
        [String][Parameter(Position = 1, Mandatory)]$Message,
        [Int][Parameter(Position = 2)]$IndentLevel = 0
    )

    switch ($Level) {
        ([DevLogLevel]::WARN) {
            Set-Variable -Option Constant Emoji (Get-Emoji '26A0')
        }
        ([DevLogLevel]::ERROR) {
            Set-Variable -Option Constant Emoji (Get-Emoji '274C')
        }
        Default {}
    }

    Set-Variable -Option Constant Indent ([String]$('   ' * $IndentLevel))
    Set-Variable -Option Constant Date ([String]$((Get-Date).ToString()))

    return ([String]"[$Date]$Indent$Emoji $Message")
}
