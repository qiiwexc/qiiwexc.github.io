function Update-FileDependency {
    param(
        [FileDependency][Parameter(Position = 0, Mandatory)]$Dependency,
        [String][Parameter(Position = 1, Mandatory)]$WipPath
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

            [Version]$FileVersion = $File.VersionInfo.FileVersionRaw
            if ($FileVersion) {
                $NewVersions.Add($FileVersion)
            }
        } catch {
            Write-LogWarning "File '$FileName' not found. Skipping." $LogIndentLevel
            continue
        }
    }

    if ($NewVersions.Count -eq 0) {
        Write-LogWarning "No valid files found for dependency '$Name'. Skipping." $LogIndentLevel
        return
    }

    Set-Variable -Option Constant SortedVersions ([Version[]]($NewVersions | Sort-Object { [Version]$_ } -Descending))
    Set-Variable -Option Constant LatestVersion ([String]($SortedVersions[0]))

    if ($LatestVersion -ne $Dependency.version) {
        Set-NewVersion $Dependency $LatestVersion
        return
    }
}
