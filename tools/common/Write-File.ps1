function Write-File {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Path,
        [String][Parameter(Position = 1, Mandatory)]$Content
    )

    $null = New-Item $Path -Value ($Content.TrimEnd() -replace "`r`n", "`n") -Force
}
