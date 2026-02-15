function Write-LogInfo {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Write-Host ([String](Format-Message ([DevLogLevel]::INFO) $Message -IndentLevel $Level))
}

function Write-LogWarning {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Write-Warning ([String](Format-Message ([DevLogLevel]::WARN) $Message -IndentLevel $Level))
}

function Write-LogError {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Message,
        [Parameter(Position = 1)][Int]$Level = 0
    )

    Write-Error ([String](Format-Message ([DevLogLevel]::ERROR) $Message -IndentLevel $Level))
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

    return [Char]::ConvertFromUtf32(([Convert]::ToInt32($Code, 16)))
}


function Format-Message {
    param(
        [Parameter(Position = 0, Mandatory)][DevLogLevel]$Level,
        [Parameter(Position = 1, Mandatory)][String]$Message,
        [Parameter(Position = 2)][Int]$IndentLevel = 0
    )

    [String]$Emoji = ''

    switch ($Level) {
        ([DevLogLevel]::WARN) {
            $Emoji = ConvertTo-Emoji '26A0'
        }
        ([DevLogLevel]::ERROR) {
            $Emoji = ConvertTo-Emoji '274C'
        }
    }

    if (-not $ACTIVITIES -or $ACTIVITIES.Count -le 0) {
        Set-Variable -Option Constant Indent ([Int]$IndentLevel)
    } else {
        Set-Variable -Option Constant Indent ([Int]($ACTIVITIES.Count - 1 + $IndentLevel))
    }

    Set-Variable -Option Constant IndentSpaces ([String]$('   ' * $Indent))
    Set-Variable -Option Constant Date ([String]$((Get-Date).ToString()))

    return ([String]"[$Date]$IndentSpaces$Emoji $Message")
}
