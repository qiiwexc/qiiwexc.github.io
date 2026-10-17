function Update-FileDependency {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][PSObject]$Dependency,
        [Parameter(Position = 1, Mandatory)][ValidateNotNullOrEmpty()][String]$WipPath
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Set-Variable -Option Constant Name ([String]$Dependency.name)

    Set-Variable -Option Constant FileName64 ([String]"$Name.exe")
    Set-Variable -Option Constant FileName32 ([String]"$Name x86.exe")

    [Collections.Generic.List[Version]]$NewVersions = @()

    foreach ($FileName in @($FileName64, $FileName32)) {
        Write-LogInfo "Checking file: $FileName" $LogIndentLevel

        try {
            [IO.FileInfo]$File = Get-Item "$WipPath\$FileName" -ErrorAction Stop
        } catch {
            # The files are put there by hand for a local run, so most runs, the nightly's among them, find none
            Write-LogInfo "File '$FileName' not found. Skipping." $LogIndentLevel
            continue
        }

        [Version]$FileVersion = if ($File.VersionInfo) { $File.VersionInfo.FileVersionRaw } else { $null }
        if ($FileVersion) {
            $NewVersions.Add($FileVersion)
        } else {
            Write-LogWarning "File '$FileName' has no version information. Skipping." $LogIndentLevel
        }
    }

    if ($NewVersions.Count -eq 0) {
        Write-LogInfo "No valid files found for dependency '$Name'. Skipping." $LogIndentLevel
        return
    }

    Set-Variable -Option Constant SortedVersions ([Version[]]($NewVersions | Sort-Object { [Version]$_ } -Descending))
    Set-Variable -Option Constant LatestVersion ([String]($SortedVersions[0]))

    if ($LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return
    }
}
