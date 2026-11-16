#Requires -Version 5

param(
    # The launcher passes its own folder. The script started on its own, as the release asset it also is, works in
    # its own folder too, rather than at the root of whatever drive is current
    [Parameter(Position = 0)][String]$WorkingDirectory = $PSScriptRoot,
    [Switch]$DevMode
)
