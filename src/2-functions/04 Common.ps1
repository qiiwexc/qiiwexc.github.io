Function Get-NetworkAdapter {
    Return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
}

Function Get-ConnectionStatus {
    if (!(Get-NetworkAdapter)) {
        Return 'Computer is not connected to the Internet'
    }
}

Function Reset-State {
    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_TEMP_DIR
    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Host ''
}

Function Exit-Script {
    Reset-State
    $FORM.Close()
}


Function Open-InBrowser {
    Param([String][Parameter(Position = 0, Mandatory = $True)]$URL)

    Add-Log $INF "Opening URL in the default browser: $URL"

    try {
        [System.Diagnostics.Process]::Start($URL)
    } catch [Exception] {
        Add-Log $ERR "Could not open the URL: $($_.Exception.Message)"
    }
}
