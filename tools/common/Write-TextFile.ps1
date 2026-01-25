function Write-TextFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Path,
        [String[]][Parameter(Position = 1, Mandatory)]$Content,
        [Switch]$Normalize = $False,
        [Switch]$NoNewLine
    )

    if ($Normalize) {
        $Null = New-Item $Path -Value (($Content.TrimEnd() -replace "`r`n", "`n") + "`n") -Force
    } else {
        Set-Content $Path $Content -NoNewline:$NoNewLine
    }
}
