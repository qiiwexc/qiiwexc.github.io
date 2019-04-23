$SourcePath = '.\src'
$DistPath = '.\d'
$DistFileName = 'qiiwexc.ps1'
$VersionFile = "$DistPath\version"

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

$TargetFile = "$DistPath\$DistFileName"
$INF = 'INF'
$WRN = 'WRN'

function Add-Log($Level, $Message) {
    $Timestamp = (Get-Date).ToString()
    $Text = "[$Timestamp] $Message"
    switch ($Level) { $WRN {Write-Warning $Text} $INF {Write-Host $Text} Default {Write-Host $Message} }
}

function Start-Build {
    $Version = Get-Date -Format 'y.M.d'

    Add-Log $INF 'Build task started'
    Add-Log $INF "Source path = $SourcePath"
    Add-Log $INF "Target file = $TargetFile"
    Add-Log $INF "Version     = $Version"

    Remove-Item $TargetFile -Force -ErrorAction Ignore
    Remove-Item $VersionFile -Force -ErrorAction Ignore
    New-Item $DistPath -ItemType Directory -Force | Out-Null

    Add-Log $INF 'Writing version file'
    Add-Content $VersionFile $Version

    Add-Log $INF 'Building...'
    Add-Content $TargetFile "`$VERSION = '$Version'"

    foreach ($File in Get-ChildItem $SourcePath -Recurse -File) {
        $FileName = $File.ToString().Replace('.ps1', '')
        $SectionName = $FileName.Remove(0, 3)
        $Repetitions = 30 - [Math]::Round(($SectionName.length + 1) / 4)
        $Spacer = '#-' * $Repetitions

        Add-Content $TargetFile "`n`n$Spacer# $SectionName $Spacer#`n"
        Add-Content $TargetFile (Get-Content $File.FullName)
        Start-Sleep -m 5
    }

    Add-Log $INF 'Finished'
}

function Start-BuildAndRun {
    Start-Build
    Add-Log $INF "Running $TargetFile"
    Start-Process 'powershell' ".\$TargetFile"
}

if ($args[0] -eq '--and-run') {Start-BuildAndRun} else {Start-Build}
