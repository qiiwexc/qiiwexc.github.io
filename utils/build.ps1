Set-Variable -Option Constant Version     (Get-Date -Format 'y.M.d')
Set-Variable -Option Constant ProjectName 'qiiwexc'

Set-Variable -Option Constant SourcePath '.\src'
Set-Variable -Option Constant DistPath   '.\d'

Set-Variable -Option Constant VersionFile     "$DistPath\version"
Set-Variable -Option Constant OutputFile      "$DistPath\$ProjectName.ps1"
Set-Variable -Option Constant BatchFile       "$DistPath\$ProjectName.bat"
Set-Variable -Option Constant ThumbprintPath  ".\certificate\$ProjectName.txt"
Set-Variable -Option Constant TimestampServer 'http://timestamp.digicert.com'

Set-Variable -Option Constant WebPageFile ".\index.html"
Set-Variable -Option Constant HtmlTitle   "<title>$ProjectName $Version</title>"
Set-Variable -Option Constant HtmlHeader  "<h2><a href=`"d/$ProjectName.bat`">$ProjectName $Version</a></h2>"

Set-Variable -Option Constant INF 'INF'
Set-Variable -Option Constant WRN 'WRN'
Set-Variable -Option Constant ERR 'ERR'


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


Function Start-Build {
    Param([Switch]$AndRun)

    Add-Log $INF 'Build task started'
    Add-Log $INF "Version     = $Version"
    Add-Log $INF "Source path = $SourcePath"
    Add-Log $INF "Output file = $OutputFile"

    Remove-Item -Force -ErrorAction SilentlyContinue $VersionFile
    Remove-Item -Force -ErrorAction SilentlyContinue $OutputFile
    Remove-Item -Force -ErrorAction SilentlyContinue $BatchFile

    New-Item -Force -ItemType Directory $DistPath | Out-Null

    Add-Log $INF 'Writing version file'
    Set-Content $VersionFile "$Version`n" -NoNewline

    Add-Log $INF 'Updating version on the web page'
    (Get-Content $WebPageFile) | ForEach-Object { $_ -Replace "<title>.+", $HtmlTitle -Replace "<h2>.+", $HtmlHeader } | Set-Content $WebPageFile

    Add-Log $INF 'Building...'

    [String[]]$PowerShellStrings = New-PowerShell $Version $SourcePath $OutputFile

    New-Batch $PowerShellStrings

    Set-Signature $OutputFile $ThumbprintPath

    Add-Log $INF 'Finished'

    if ($AndRun) {
        Add-Log $INF "Running $OutputFile"
        Start-Process 'PowerShell' ".\$OutputFile"
    }
}


Function New-PowerShell {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$Version,
        [String][Parameter(Position = 1, Mandatory = $True)]$SourcePath,
        [String][Parameter(Position = 2, Mandatory = $True)]$OutputFile
    )

    [String[]]$OutputStrings = "Set-Variable -Option Constant Version ([Version]'$Version')"

    ForEach ($File In Get-ChildItem -Recurse -File $SourcePath) {
        [String]$SectionName = $File.ToString().Replace('.ps1', '').Remove(0, 3)
        [String]$Spacer = '=-' * (30 - [Math]::Round(($SectionName.length + 1) / 4))

        $OutputStrings += "`n`n#$Spacer# $SectionName #$Spacer#`n"

        ForEach ($Line In (Get-Content $File.FullName)) {
            $OutputStrings += $Line
        }
    }

    Add-Log $INF "Writing output file $OutputFile"
    $OutputStrings | Out-File $OutputFile -Encoding ASCII

    Return $OutputStrings
}


Function New-Batch {
    Param(
        [String[]][Parameter(Position = 0)]$PowerShellStrings
    )

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
}

Function Set-Signature {
    Param(
        [String][Parameter(Position = 0, Mandatory = $True)]$OutputFile,
        [String][Parameter(Position = 1, Mandatory = $True)]$ThumbprintPath
    )

    Add-Log $INF 'Signing...'

    [String]$Thumbprint = Get-Content $ThumbprintPath

    $CodeSignCert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {$_.Thumbprint -eq $Thumbprint}

    Set-AuthenticodeSignature -FilePath $OutputFile -Certificate $CodeSignCert -TimestampServer $TimestampServer

    Add-Log $INF 'Signed'
}


Start-Build -AndRun:$($args[0] -eq '--and-run')
