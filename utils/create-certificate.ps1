#Requires -PSEdition Desktop
#Requires -Version 3

Set-Variable -Option Constant IsElevated $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))

Set-Variable -Option Constant ProjectName 'qiiwexc'

Set-Variable -Option Constant TargetFile "..\d\$ProjectName.ps1"
Set-Variable -Option Constant CertificatePath "..\certificate\$ProjectName.cer"
Set-Variable -Option Constant ThumbprintPath "..\certificate\$ProjectName.txt"

Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


function Write-Log {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"

    switch ($Level) {
        $INF {
            Write-Host $Text
        }
        $WRN {
            Write-Warning $Text
        }
        $ERR {
            Write-Error $Text
        }
        Default {
            Write-Host $Text
        }
    }
}


function Out-Success {
    Write-Log $INF '   > Done'
}

function Out-Failure {
    Write-Log $INF '   > Failed'
}


function Write-ExceptionLog {
    param(
        [PSCustomObject][Parameter(Position = 0, Mandatory = $True)]$Exception,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Write-Log $ERR "$($Message): $($Exception.Exception.Message)"
}


function Start-Elevated {
    if (-not $IsElevated) {
        Write-Log $INF 'Requesting administrator privileges...'

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

    Write-Log $INF 'Creating a new certificate...'
    $Certificate = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -Subject "CN=$ProjectName" -KeySpec Signature -Type CodeSigningCert
    Out-Success

    Write-Log $INF "Creating the certificate to  '$CertificatePath'..."
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
