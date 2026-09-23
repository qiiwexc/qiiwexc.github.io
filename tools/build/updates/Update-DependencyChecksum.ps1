function Update-DependencyChecksum {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNull()][Dependency]$Dependency,
        [Parameter(Position = 1, Mandatory)][ValidateNotNullOrEmpty()][String]$UrlsFile
    )

    Set-Variable -Option Constant LogIndentLevel ([Int]1)

    Set-Variable -Option Constant UrlsTemplate ([PSCustomObject](Read-JsonFile $UrlsFile))
    Set-Variable -Option Constant UrlKey ([String]"URL_$($Dependency.name.ToUpper().Replace(' ', '_').Replace('-', '_'))")

    # Only downloads with a versioned URL are pinned by checksum
    if (-not $UrlsTemplate.PSObject.Properties[$UrlKey] -or -not $UrlsTemplate.$UrlKey.Contains('{VERSION}')) {
        return $True
    }

    Set-Variable -Option Constant Uri ([String]$UrlsTemplate.$UrlKey.Replace('{VERSION}', $Dependency.version.TrimStart('v')))

    if (-not $Uri.StartsWith('https://')) {
        Out-Failure "Refusing to download '$Uri' for a checksum: only HTTPS is allowed" $LogIndentLevel
        return $False
    }

    Write-LogInfo "Computing checksum of $Uri" $LogIndentLevel

    Set-Variable -Option Constant TempFile ([String][IO.Path]::GetTempFileName())
    try {
        Invoke-WebRequest $Uri -UseBasicParsing -OutFile $TempFile -TimeoutSec 300 -ErrorAction Stop
        Set-Variable -Option Constant Checksum ([String](Get-FileHash $TempFile -Algorithm SHA256 -ErrorAction Stop).Hash.ToLower())
    } catch {
        Out-Failure "Failed to compute checksum of '$Uri': $_" $LogIndentLevel
        return $False
    } finally {
        Remove-Item $TempFile -Force -ErrorAction SilentlyContinue
    }

    Write-LogInfo "New checksum: $Checksum" $LogIndentLevel
    $Dependency | Add-Member -NotePropertyName 'sha256' -NotePropertyValue $Checksum -Force

    return $True
}
