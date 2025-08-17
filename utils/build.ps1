Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


Function Start-Build {
    Param([Switch]$AndRun)

    Set-Variable -Option Constant Version     (Get-Date -Format 'y.M.d')
    Set-Variable -Option Constant ProjectName 'qiiwexc'

    Set-Variable -Option Constant SourcePath '.\src'
    Set-Variable -Option Constant DistPath   '.\d'

    Set-Variable -Option Constant VersionFile "$DistPath\version"
    Set-Variable -Option Constant Ps1File     "$DistPath\$ProjectName.ps1"
    Set-Variable -Option Constant BatchFile   "$DistPath\$ProjectName.bat"

    Add-Log $INF 'Build task started'
    Add-Log $INF "Version     = $Version"
    Add-Log $INF "Source path = $SourcePath"
    Add-Log $INF "Output file = $Ps1File"

    Write-VersionFile $Version $VersionFile

    Update-Html $ProjectName $Version

    New-PowerShell $Version $SourcePath $Ps1File

    Set-Signature $Ps1File $ProjectName

    New-Batch $Ps1File $BatchFile

    Add-Log $INF 'Build finished'

    if ($AndRun) {
        Add-Log $INF "Running $Ps1File"
        Start-Process 'PowerShell' ".\$Ps1File"
    }
}


Function Add-Log {
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


Function Write-VersionFile {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Version,
        [String][Parameter(Position = 1, Mandatory = $True)]$VersionFile
    )

    Add-Log $INF 'Writing version file...'

    Remove-Item -Force -ErrorAction SilentlyContinue $VersionFile

    Set-Content $VersionFile "$Version`n" -NoNewline

    Add-Log $INF 'Done'
}


Function Update-Html {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$ProjectName,
        [String][Parameter(Position = 1, Mandatory = $True)]$Version
    )

    Add-Log $INF 'Updating version on the web page...'

    Set-Variable -Option Constant WebPageFile ".\index.html"
    Set-Variable -Option Constant HtmlTitle   "<title>$ProjectName $Version</title>"
    Set-Variable -Option Constant HtmlHeader  "<h2><a href=`"d/$ProjectName.bat`">$ProjectName $Version</a></h2>"

    (Get-Content $WebPageFile) | ForEach-Object { $_ -Replace "<title>.+", $HtmlTitle -Replace "<h2>.+", $HtmlHeader } | Set-Content $WebPageFile

    Add-Log $INF 'Done'
}


Function New-PowerShell {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Version,
        [String][Parameter(Position = 1, Mandatory = $True)]$SourcePath,
        [String][Parameter(Position = 2, Mandatory = $True)]$Ps1File
    )

    Add-Log $INF 'Building PowerShell script...'

    Remove-Item -Force -ErrorAction SilentlyContinue $Ps1File

    New-Item -Force -ItemType Directory $DistPath | Out-Null

    [String[]]$OutputStrings = "Set-Variable -Option Constant Version ([Version]'$Version')"

    ForEach ($File In Get-ChildItem -Recurse -File $SourcePath) {
        [String]$SectionName = $File.ToString().Replace('.ps1', '').Remove(0, 3)
        [String]$Spacer = '=-' * (30 - [Math]::Round(($SectionName.length + 1) / 4))

        $OutputStrings += "`n`n#$Spacer# $SectionName #$Spacer#`n"

        ForEach ($Line In (Get-Content $File.FullName)) {
            $OutputStrings += $Line
        }
    }

    Add-Log $INF "Writing output file $Ps1File"
    $OutputStrings | Out-File $Ps1File -Encoding ASCII

    Add-Log $INF 'Done'
}


Function New-Batch {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory = $True)]$BatchFile
    )

    Add-Log $INF 'Building batch script...'

    Remove-Item -Force -ErrorAction SilentlyContinue $BatchFile

    [String[]]$PowerShellStrings = Get-Content $Ps1File

    [String[]]$BatchStrings = "@echo off`n"
    $BatchStrings += "set `"psfile=%temp%\$ProjectName.ps1`"`n"
    $BatchStrings += '> "%psfile%" ('
    $BatchStrings += "  for /f `"delims=`" %%A in ('findstr `"^::`" `"%~f0`"') do ("
    $BatchStrings += '    set "line=%%A"'
    $BatchStrings += '    setlocal enabledelayedexpansion'
    $BatchStrings += '    echo(!line:~2!'
    $BatchStrings += '    endlocal'
    $BatchStrings += '  )'
    $BatchStrings += ")`n"
    $BatchStrings += 'powershell -ExecutionPolicy Bypass "%psfile%" "%cd%"'
    $BatchStrings += "`n"

    ForEach ($String In $PowerShellStrings) {
        $BatchStrings += "::$($String -Replace "`n", "`n::")"
    }

    Add-Log $INF "Writing batch file $BatchFile"
    $BatchStrings | Out-File $BatchFile -Encoding ASCII

    Add-Log $INF 'Done'
}

Function Set-Signature {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Ps1File,
        [String][Parameter(Position = 1, Mandatory = $True)]$ProjectName
    )

    Add-Log $INF 'Signing...'

    Set-Variable -Option Constant ThumbprintPath ".\certificate\$ProjectName.txt"
    Set-Variable -Option Constant TimestampServer 'http://timestamp.digicert.com'

    [String]$Thumbprint = Get-Content $ThumbprintPath

    $CodeSignCert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {$_.Thumbprint -eq $Thumbprint}

    Set-AuthenticodeSignature -FilePath $Ps1File -Certificate $CodeSignCert -TimestampServer $TimestampServer | Out-Null

    Add-Log $INF 'Done'
}


Start-Build -AndRun:$($args[0] -eq '--and-run')
