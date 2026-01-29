function Write-TextFile {
    param(
        [ValidateNotNullOrEmpty()][String][Parameter(Position = 0, Mandatory)]$Path,
        [AllowEmptyString()][String[]][Parameter(Position = 1, Mandatory)]$Content,
        [Switch]$Normalize = $False,
        [Switch]$NoNewLine
    )

    if ($Normalize) {
        $Null = New-Item $Path -Value (($Content.TrimEnd() -replace "`r`n", "`n") + "`n") -Force
    } else {
        Set-Content $Path $Content -NoNewline:$NoNewLine
    }
}
