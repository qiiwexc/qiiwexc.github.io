$SourcePath = '.\src'
$DistPath = '.\d'
$DistFileName = 'qiiwexc.ps1'
$VersionFile = "$DistPath\version"

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TargetFile = "$DistPath\$DistFileName"
$INF = 'INF'
$WRN = 'WRN'

function Write-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    switch ($Level) { $WRN {Write-Warning $Text} $INF {Write-Host $Text} Default {Write-Host $Message} }
}

function Build {
    $Version = Get-Date -Format 'y.M.d'

    Write-Log $INF 'Build task started'
    Write-Log $INF "Source path = $SourcePath"
    Write-Log $INF "Target file = $TargetFile"
    Write-Log $INF "Version     = $Version"

    Remove-Item $TargetFile -Force -ErrorAction Ignore
    Remove-Item $VersionFile -Force -ErrorAction Ignore
    New-Item $DistPath -ItemType Directory -Force | Out-Null

    Write-Log $INF 'Writing version file'
    Add-Content $VersionFile $Version

    Write-Log $INF 'Building...'
    Add-Content $TargetFile "`$VERSION = '$Version'"

    foreach ($File in Get-ChildItem -Path $SourcePath -Recurse -File) {
        $FileName = $File.ToString().Replace('.ps1', '')
        $SectionName = $FileName.Remove(0, 3)
        $Repetitions = 30 - [Math]::Round(($SectionName.length + 1) / 4)
        $Spacer = '#-' * $Repetitions

        Add-Content $TargetFile "`r`n`r`n$Spacer# $SectionName $Spacer#`r`n"
        Add-Content $TargetFile (Get-Content -Path $File.FullName)
    }

    Write-Log $INF 'Finished'
}

function BuildAndRun {
    Build
    Write-Log $INF "Running $TargetFile"
    Start-Process powershell.exe ".\$TargetFile"
}

if ($args[0] -eq '--and-run') {BuildAndRun} else {Build}
