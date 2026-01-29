function Write-JsonFile {
    param(
        [ValidateNotNullOrEmpty()][String][Parameter(Position = 0, Mandatory)]$Path,
        [ValidateNotNull()][PSObject][Parameter(Position = 1, Mandatory)]$Content
    )

    Write-TextFile $Path ($Content | ConvertTo-Json -Depth 10) -Normalize
}
