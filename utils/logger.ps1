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
    Write-Log 'WARN' $Message
}

function Write-LogError {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Message
    )
    Write-Log 'ERROR' $Message
}

function Out-Success {
    Write-LogInfo '   > Done'
}

function Out-Failure {
    Write-LogInfo '   > Failed'
}

function Write-ExceptionLog {
    param(
        [Object][Parameter(Position = 0, Mandatory = $True)]$Exception,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Write-LogError "$($Message): $($Exception.Exception.Message)"
}

function Write-Log {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INFO', 'WARN', 'ERROR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
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
