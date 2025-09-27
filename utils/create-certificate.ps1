#Requires -PSEdition Desktop
#Requires -Version 3

Set-Variable -Option Constant IsElevated $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))

Set-Variable -Option Constant ProjectName 'qiiwexc'

Set-Variable -Option Constant TargetFile "..\d\$ProjectName.ps1"
Set-Variable -Option Constant CertificatePath "..\certificate\$ProjectName.cer"
Set-Variable -Option Constant ThumbprintPath "..\certificate\$ProjectName.txt"


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


function Out-Success {
    Write-LogInfo '   > Done'
}

function Out-Failure {
    Write-LogInfo '   > Failed'
}


function Write-ExceptionLog {
    param(
        [PSCustomObject][Parameter(Position = 0, Mandatory = $True)]$Exception,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Write-LogError "$($Message): $($Exception.Exception.Message)"
}


function Start-Elevated {
    if (-not $IsElevated) {
        Write-LogInfo 'Requesting administrator privileges...'

        try {
            Start-Process PowerShell -Verb RunAs "-ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`""
        } catch [Exception] {
            Write-ExceptionLog $_ 'Failed to gain administrator privileges'
        }

        exit
    }
}


function New-Certificate {
    Start-Elevated

    Remove-Item -Force -ErrorAction SilentlyContinue $CertificatePath
    Remove-Item -Force -ErrorAction SilentlyContinue $ThumbprintPath

    Write-LogInfo 'Creating a new certificate...'
    $Certificate = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -Subject "CN=$ProjectName" -KeySpec Signature -Type CodeSigningCert
    Out-Success

    Write-LogInfo "Creating the certificate to  '$CertificatePath'..."
    Export-Certificate -Cert $Certificate -FilePath $CertificatePath
    Out-Success

    try {
        Get-Item $CertificatePath | Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root'
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to import certificates'
        return
    }

    $Certificate.Thumbprint | Out-File $ThumbprintPath
}

New-Certificate
