function Write-JsonFile {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Path,
        [PSCustomObject][Parameter(Position = 1, Mandatory)]$Content
    )

    Write-TextFile $Path ($Content | ConvertTo-Json -Depth 10) -Normalize
}
