function New-Directory {
    param(
        [String][Parameter(Position = 0, Mandatory)]$Path
    )

    $Null = New-Item -Force -ItemType Directory $Path -ErrorAction Stop
}
