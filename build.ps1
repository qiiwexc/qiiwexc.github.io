$SourcePath = '.\src'
$DistPath = '.\d'
$DistFileName = 'qiiwexc.ps1'
$VersionFile = "$DistPath\version"

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TargetFile = "$DistPath\$DistFileName"
$_INF = 'INF'
$_WRN = 'WRN'

function Write-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    switch ($Level) { $_WRN {Write-Warning $Text} $_INF {Write-Host $Text} Default {Write-Host $Message} }
}

function Build {
    $Version = Get-Date -Format 'y.M.d'

    Write-Log $_INF 'Build task started'
    Write-Log $_INF "Source path = $SourcePath"
    Write-Log $_INF "Target file = $TargetFile"
    Write-Log $_INF "Version     = $Version"

    Remove-Item $TargetFile -Force -ErrorAction Ignore
    Remove-Item $VersionFile -Force -ErrorAction Ignore
    New-Item $DistPath -ItemType Directory -Force | Out-Null

    Write-Log $_INF 'Writing version file'
    Add-Content $VersionFile $Version

    Write-Log $_INF 'Building...'
    Add-Content $TargetFile "`$_VERSION = '$Version'"

    foreach ($File in Get-ChildItem -Path $SourcePath -Recurse -File) {
        $FileName = $File.ToString().Replace('.ps1', '')
        $SectionName = $FileName.Remove(0, 3)
        $Repetitions = 30 - [Math]::Round(($SectionName.length + 1) / 4)
        $Spacer = '#-' * $Repetitions

        Add-Content $TargetFile "`r`n`r`n$Spacer# $SectionName $Spacer#`r`n"
        Add-Content $TargetFile (Get-Content -Path $File.FullName)
    }

    Write-Log $_INF 'Finished'
}

function BuildAndRun {
    Build
    Write-Log $_INF "Running $TargetFile"
    Start-Process powershell.exe ".\$TargetFile"
}

if ($args[0] -eq '--and-run') {BuildAndRun} else {Build}
