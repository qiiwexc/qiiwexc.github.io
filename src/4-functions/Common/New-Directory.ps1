function New-Directory {
    param(
        [Parameter(Position = 0, Mandatory)][String]$Path
    )

    $Null = New-Item -Force -ItemType Directory $Path -ErrorAction Stop
}
