function Write-JsonFile {
    param(
        [Parameter(Position = 0, Mandatory)][ValidateNotNullOrEmpty()][String]$Path,
        [Parameter(Position = 1, Mandatory)][ValidateNotNull()][PSObject]$Content
    )

    Write-TextFile $Path ($Content | ConvertTo-Json -Depth 10) -Normalize
}
