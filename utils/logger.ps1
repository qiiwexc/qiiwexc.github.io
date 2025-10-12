function Write-LogInfo {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message
    )
    Write-Log 'INFO' $Message
}

function Write-LogWarning {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message
    )
    Write-Log 'WARN' "$(Get-Emoji '26A0') $Message"
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Message
    )
    Write-Log 'ERROR' "$(Get-Emoji '274C') $Message"
}

function Out-Success {
    Write-LogInfo "   > Done $(Get-Emoji '2705')"
}

function Out-Failure {
    Write-LogInfo "   > Failed $(Get-Emoji '274C')"
}

function Write-LogException {
    param(
        [Object][Parameter(Position = 0, Mandatory)]$Exception,
        [String][Parameter(Position = 1, Mandatory)]$Message
    )

    Write-LogError "$($Message): $($Exception.Exception.Message)"
}

function Write-Log {
    param(
        [String][Parameter(Position = 0, Mandatory)][ValidateSet('INFO', 'WARN', 'ERROR')]$Level,
        [String][Parameter(Position = 1, Mandatory)]$Message
    )

    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"

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

function Get-Emoji {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Code
    )

    Set-Variable -Option Constant Emoji ([Convert]::toInt32($Code, 16))

    return [Char]::ConvertFromUtf32($Emoji)
}
