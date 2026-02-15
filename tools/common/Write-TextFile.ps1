function Write-TextFile {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path,
        [Parameter(Position = 1, Mandatory)][AllowEmptyString()][String[]]$Content,
        [Switch]$Normalize,
        [Switch]$NoNewLine
    )

    if ($Normalize) {
        $Null = New-Item $Path -Value (($Content.TrimEnd() -replace "`r`n", "`n") + "`n") -Force
    } else {
        Set-Content $Path $Content -NoNewline:$NoNewLine
    }
}
