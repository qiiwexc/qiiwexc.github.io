function Invoke-7Zip {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ExtractionPath,
        [Parameter(Position = 1, Mandatory)][String]$ZipPath
    )

    & $PATH_7ZIP_EXE x -o"$ExtractionPath" -y "$ZipPath" | Out-Null
}
