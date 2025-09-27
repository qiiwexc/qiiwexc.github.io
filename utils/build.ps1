#Requires -PSEdition Desktop
#Requires -Version 3

param(
    [Switch]$Run
)


function Start-Build {
    param(
        [Switch]$Run
    )

    Set-Variable -Option Constant Version (Get-Date -Format 'y.M.d')
    Set-Variable -Option Constant ProjectName 'qiiwexc'

    Set-Variable -Option Constant AssetsPath '.\assets'
    Set-Variable -Option Constant SourcePath '.\src'
    Set-Variable -Option Constant DistPath '.\d'

    Set-Variable -Option Constant VersionFile "$DistPath\version"
    Set-Variable -Option Constant Ps1File "$DistPath\$ProjectName.ps1"
    Set-Variable -Option Constant BatchFile "$DistPath\$ProjectName.bat"

    Write-LogInfo 'Build task started'
    Write-LogInfo "Version     = $Version"
    Write-LogInfo "Source path = $SourcePath"
    Write-LogInfo "Output file = $Ps1File"

    Write-VersionFile $Version $VersionFile

    Set-Variable -Option Constant Config (Get-Config $AssetsPath $Version)

    New-HtmlFile $AssetsPath $Config

    New-PowerShellScript $SourcePath $Ps1File -Config:$Config

    Add-Signature $Ps1File $ProjectName

    New-BatchScript $Ps1File $BatchFile

    Write-LogInfo 'Build finished'

    if ($Run) {
        Write-LogInfo "Running $BatchFile"
        Start-Process 'PowerShell' ".\$BatchFile Debug"
    }
}


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


function Write-VersionFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Version,
        [String][Parameter(Position = 1, Mandatory = $True)]$VersionFile
    )

    Write-LogInfo 'Writing version file...'

    Remove-Item -Force -ErrorAction SilentlyContinue $VersionFile

    $Version | Out-File $VersionFile -Encoding ASCII

    Out-Success
}


function Get-Config {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AssetsPath,
        [String][Parameter(Position = 1, Mandatory = $True)]$Version
    )

    Write-LogInfo 'Loading config...'

    Set-Variable -Option Constant UrlsFile "$AssetsPath\urls.json"

    [System.Object[]]$Config = Get-Content $UrlsFile | ConvertFrom-Json
    $Config += @{key = 'PROJECT_VERSION'; value = $Version }

    Out-Success

    return $Config
}


function New-HtmlFile {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AssetsPath,
        [System.Object[]][Parameter(Position = 1, Mandatory = $True)]$Config
    )

    Write-LogInfo 'Building the web page...'

    Set-Variable -Option Constant TemplateFile "$AssetsPath\template.html"
    Set-Variable -Option Constant OutputFile '.\index.html'

    [String[]]$TemplateContent = Get-Content $TemplateFile

    $Config | ForEach-Object { $TemplateContent = $TemplateContent -replace "{$($_.key)}", $_.value }

    $TemplateContent = $TemplateContent -replace '../d/stylesheet.css', 'https://bit.ly/stylesheet_web'

    $TemplateContent | Out-File $OutputFile

    Out-Success
}


function New-PowerShellScript {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$SourcePath,
        [String][Parameter(Position = 1, Mandatory = $True)]$Ps1File,
        [System.Object[]][Parameter(Position = 2, Mandatory = $True)]$Config
    )

    Write-LogInfo 'Building PowerShell script...'

    Remove-Item -Force -ErrorAction SilentlyContinue $Ps1File

    New-Item -Force -ItemType Directory $DistPath | Out-Null

    [String[]]$OutputStrings = @()

    foreach ($File in Get-ChildItem -Recurse -File $SourcePath) {
        [String]$SectionName = $File.ToString().Replace('.ps1', '').Remove(0, 3)
        [String]$Spacer = '=-' * (30 - [Math]::Round(($SectionName.length + 1) / 4))

        $OutputStrings += "`n`n#$Spacer# $SectionName #$Spacer#`n"
        $OutputStrings += Get-Content $File.FullName
    }

    $Config | ForEach-Object { $OutputStrings = $OutputStrings -replace "{$($_.key)}", $_.value }

    Write-LogInfo "Writing output file $Ps1File"
    $OutputStrings | Out-File $Ps1File

    Out-Success
}


function New-BatchScript {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory = $True)]$BatchFile
    )

    Write-LogInfo 'Building batch script...'

    Remove-Item -Force -ErrorAction SilentlyContinue $BatchFile

    [String[]]$PowerShellStrings = Get-Content $Ps1File

    [String[]]$BatchStrings = "@echo off`n"
    $BatchStrings += "if `"%~1`"==`"Debug`" set debug=true`n"
    $BatchStrings += "set `"psfile=%temp%\$ProjectName.ps1`"`n"
    $BatchStrings += '> "%psfile%" ('
    $BatchStrings += "  for /f `"delims=`" %%A in ('findstr `"^::`" `"%~f0`"') do ("
    $BatchStrings += '    set "line=%%A"'
    $BatchStrings += '    setlocal enabledelayedexpansion'
    $BatchStrings += '    echo(!line:~2!'
    $BatchStrings += '    endlocal'
    $BatchStrings += '  )'
    $BatchStrings += ")`n"
    $BatchStrings += 'if "%debug%"=="true" ('
    $BatchStrings += '  powershell -ExecutionPolicy Bypass "%psfile%" -CallerPath "%cd%"'
    $BatchStrings += ') else ('
    $BatchStrings += '  powershell -ExecutionPolicy Bypass "%psfile%" -CallerPath "%cd%" -HideConsole'
    $BatchStrings += ")`n"

    foreach ($String in $PowerShellStrings) {
        $BatchStrings += "::$($String -Replace "`n", "`n::")"
    }

    Write-LogInfo "Writing batch file $BatchFile"
    $BatchStrings | Out-File $BatchFile -Encoding ASCII

    Out-Success
}

function Add-Signature {
    param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory = $True)]$ProjectName
    )

    Write-LogInfo 'Signing...'

    Set-Variable -Option Constant ThumbprintPath ".\certificate\$ProjectName.txt"
    Set-Variable -Option Constant TimestampServer 'http://timestamp.digicert.com'

    [String]$Thumbprint = Get-Content $ThumbprintPath

    $CodeSignCert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $Thumbprint }

    Set-AuthenticodeSignature -FilePath $Ps1File -Certificate $CodeSignCert -TimestampServer $TimestampServer | Out-Null

    Out-Success
}


Start-Build -Run:$Run
