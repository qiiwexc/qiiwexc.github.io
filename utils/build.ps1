param([Switch]$Run)

Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Function Start-Build {
    Param([Switch]$Run)

    Set-Variable -Option Constant Version     (Get-Date -Format 'y.M.d')
    Set-Variable -Option Constant ProjectName 'qiiwexc'

    Set-Variable -Option Constant AssetsPath '.\assets'
    Set-Variable -Option Constant SourcePath '.\src'
    Set-Variable -Option Constant DistPath   '.\d'

    Set-Variable -Option Constant VersionFile "$DistPath\version"
    Set-Variable -Option Constant Ps1File     "$DistPath\$ProjectName.ps1"
    Set-Variable -Option Constant BatchFile   "$DistPath\$ProjectName.bat"

    Write-Log $INF 'Build task started'
    Write-Log $INF "Version     = $Version"
    Write-Log $INF "Source path = $SourcePath"
    Write-Log $INF "Output file = $Ps1File"

    Write-VersionFile $Version $VersionFile

    Set-Variable -Option Constant Config (Get-Config $AssetsPath $Version)

    New-Html $AssetsPath $Config

    New-PowerShell $SourcePath $Ps1File $Config

    Set-Signature $Ps1File $ProjectName

    New-Batch $Ps1File $BatchFile

    Write-Log $INF 'Build finished'

    if ($Run) {
        Write-Log $INF "Running $BatchFile"
        Start-Process 'PowerShell' ".\$BatchFile Debug"
    }
}


Function Write-Log {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)][ValidateSet('INF', 'WRN', 'ERR')]$Level,
        [String][Parameter(Position = 1, Mandatory = $True)]$Message
    )

    Write-Host -NoNewline "`n[$((Get-Date).ToString())] $Message"
}

Function Out-Success {
    Write-Host -NoNewline ' Done'
}

Function Out-Failure {
    Write-Host -NoNewline ' Failed'
}


Function Write-VersionFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Version,
        [String][Parameter(Position = 1, Mandatory = $True)]$VersionFile
    )

    Write-Log $INF 'Writing version file...'

    Remove-Item -Force -ErrorAction SilentlyContinue $VersionFile

    $Version | Out-File $VersionFile

    Out-Success
}


Function Get-Config {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AssetsPath,
        [String][Parameter(Position = 1, Mandatory = $True)]$Version
    )

    Write-Log $INF 'Loading config...'

    Set-Variable -Option Constant UrlsFile "$AssetsPath\urls.json"

    [System.Object[]]$Config = Get-Content $UrlsFile | ConvertFrom-Json
    $Config += @{key='PROJECT_VERSION'; value=$Version}

    Out-Success

    return $Config
}


Function New-Html {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$AssetsPath,
        [System.Object[]][Parameter(Position = 1, Mandatory = $True)]$Config
    )

    Write-Log $INF 'Building the web page...'

    Set-Variable -Option Constant TemplateFile "$AssetsPath\template.html"
    Set-Variable -Option Constant OutputFile   '.\index.html'

    [String[]]$TemplateContent = Get-Content $TemplateFile

    $Config | ForEach-Object { $TemplateContent = $TemplateContent -Replace "{$($_.key)}", $_.value }

    $TemplateContent = $TemplateContent -Replace '../d/stylesheet.css', 'https://bit.ly/stylesheet_web'

    $TemplateContent | Out-File $OutputFile

    Out-Success
}


Function New-PowerShell {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$SourcePath,
        [String][Parameter(Position = 1, Mandatory = $True)]$Ps1File,
        [System.Object[]][Parameter(Position = 2, Mandatory = $True)]$Config
    )

    Write-Log $INF 'Building PowerShell script...'

    Remove-Item -Force -ErrorAction SilentlyContinue $Ps1File

    New-Item -Force -ItemType Directory $DistPath | Out-Null

    [String[]]$OutputStrings = @()

    ForEach ($File In Get-ChildItem -Recurse -File $SourcePath) {
        [String]$SectionName = $File.ToString().Replace('.ps1', '').Remove(0, 3)
        [String]$Spacer = '=-' * (30 - [Math]::Round(($SectionName.length + 1) / 4))

        $OutputStrings += "`n`n#$Spacer# $SectionName #$Spacer#`n"
        $OutputStrings += Get-Content $File.FullName
    }

    $Config | ForEach-Object { $OutputStrings = $OutputStrings -Replace "{$($_.key)}", $_.value }

    Write-Log $INF "Writing output file $Ps1File"
    $OutputStrings | Out-File $Ps1File

    Out-Success
}


Function New-Batch {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory = $True)]$BatchFile
    )

    Write-Log $INF 'Building batch script...'

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

    ForEach ($String In $PowerShellStrings) {
        $BatchStrings += "::$($String -Replace "`n", "`n::")"
    }

    Write-Log $INF "Writing batch file $BatchFile"
    $BatchStrings | Out-File $BatchFile -Encoding ASCII

    Out-Success
}

Function Set-Signature {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory = $True)]$ProjectName
    )

    Write-Log $INF 'Signing...'

    Set-Variable -Option Constant ThumbprintPath ".\certificate\$ProjectName.txt"
    Set-Variable -Option Constant TimestampServer 'http://timestamp.digicert.com'

    [String]$Thumbprint = Get-Content $ThumbprintPath

    $CodeSignCert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {$_.Thumbprint -eq $Thumbprint}

    Set-AuthenticodeSignature -FilePath $Ps1File -Certificate $CodeSignCert -TimestampServer $TimestampServer | Out-Null

    Out-Success
}


Start-Build -Run:$Run
