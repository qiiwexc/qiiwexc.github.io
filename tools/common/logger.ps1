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

    Write-Host ([String](Format-Message ([DevLogLevel]::INFO) $Message -IndentLevel $Level))
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Write-Warning ([String](Format-Message ([DevLogLevel]::WARN) $Message -IndentLevel $Level))
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message,
        [Int][Parameter(Position = 1)]$Level = 0
    )

    Write-Error ([String](Format-Message ([DevLogLevel]::ERROR) $Message -IndentLevel $Level))
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

    return [Char]::ConvertFromUtf32(([Convert]::toInt32($Code, 16)))
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

    if ($ACTIVITIES.Count -le 0) {
        Set-Variable -Option Constant Indent ([Int]$IndentLevel)
    } else {
        Set-Variable -Option Constant Indent ([Int]($ACTIVITIES.Count - 1 + $IndentLevel))
    }

    Set-Variable -Option Constant IndentSpaces ([String]$('   ' * $Indent))
    Set-Variable -Option Constant Date ([String]$((Get-Date).ToString()))

    return ([String]"[$Date]$IndentSpaces$Emoji $Message")
}
