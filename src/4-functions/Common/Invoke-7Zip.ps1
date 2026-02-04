function Invoke-7Zip {
    param(
        [String][Parameter(Position = 0, Mandatory)]$ExtractionPath,
        [String][Parameter(Position = 1, Mandatory)]$ZipPath
    )

    & $PATH_7ZIP_EXE x -o"$ExtractionPath" -y "$ZipPath" | Out-Null
}
