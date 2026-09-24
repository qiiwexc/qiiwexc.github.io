function Get-ElevationArguments {
    param(
        [Parameter(Position = 0, Mandatory)][String]$ScriptPath,
        [Parameter(Position = 1)][String]$WorkingDirectory,
        [Switch]$DevMode
    )

    # Quote path arguments explicitly: Start-Process joins the argument array with
    # spaces without quoting, so paths containing spaces would be split apart.
    # A trailing backslash (a drive root such as 'E:\') would escape the closing quote
    [String[]]$Arguments = @('-ExecutionPolicy', 'Bypass', '-File', "`"$ScriptPath`"", '-WorkingDirectory', "`"$($WorkingDirectory.TrimEnd('\'))`"")
    if ($DevMode) {
        $Arguments += '-DevMode'
    }

    return $Arguments
}

if (-not (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Host 'Restarting elevated...'

    try {
        Start-Process PowerShell -Verb RunAs -ArgumentList (Get-ElevationArguments $PSCommandPath $WorkingDirectory -DevMode:$DevMode)
    } catch {
        Write-Error "Failed to restart elevated: $_"
        Start-Sleep -Seconds 5
    }

    exit
}
