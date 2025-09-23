Set-Variable -Option Constant IsElevated $(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))

Set-Variable -Option Constant ProjectName 'qiiwexc'

Set-Variable -Option Constant TargetFile      "..\d\$ProjectName.ps1"
Set-Variable -Option Constant CertificatePath "..\certificate\$ProjectName.cer"
Set-Variable -Option Constant ThumbprintPath  "..\certificate\$ProjectName.txt"

Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Function Write-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Set-Variable -Option Constant Text "[$((Get-Date).ToString())] $Message"

    Switch ($Level) {
        $WRN {
            Write-Warning $Text
        }
        $INF {
            Write-Host $Text
        }
        Default {
            Write-Host $Message
        }
    }
}


Function Write-ExceptionLog {
    Param(
        [PSCustomObject][Parameter(Position = 0, Mandatory = $True)]$Exception,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Write-Log $ERR "$($Message): $($Exception.Exception.Message)"
}


Function Start-Elevated {
    if (!$IsElevated) {
        Write-Log $INF 'Requesting administrator privileges...'

        try {
            Start-Process PowerShell -Verb RunAs "-ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`""
        } catch [Exception] {
            Write-ExceptionLog $_ 'Failed to gain administrator privileges'
            Return
        }

        Exit
    }
}


Function New-Certificate {
    Start-Elevated

    Remove-Item -Force -ErrorAction SilentlyContinue $CertificatePath
    Remove-Item -Force -ErrorAction SilentlyContinue $ThumbprintPath

    Write-Log $INF "Creating a new certificate $CertificatePath"

    $Certificate = New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My -Subject "CN=$ProjectName" -KeySpec Signature -Type CodeSigningCert

    Export-Certificate -Cert $Certificate -FilePath $CertificatePath

    try {
        Get-Item $CertificatePath | Import-Certificate -CertStoreLocation "Cert:\LocalMachine\Root"
    } catch [Exception] {
        Write-ExceptionLog $_ 'Failed to import certificates'
        Return
    }

    $Certificate.Thumbprint | Out-File $ThumbprintPath -Encoding UTF8
}

New-Certificate
