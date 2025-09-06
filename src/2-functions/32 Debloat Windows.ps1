Function Start-WindowsDebloat {
    Add-Log $INF "Starting Windows debloat utility..."

    if ($OS_VERSION -eq 10) {
        Start-Script "iwr -useb https://git.io/debloat | iex"
    } else {
        Start-Script -Elevated -HideWindow "& ([scriptblock]::Create((irm 'https://debloat.raphi.re/')))"
    }

    Out-Success
}
