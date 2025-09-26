function Get-NetworkAdapter {
    return $(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True')
}

function Test-NetworkConnection {
    if (!(Get-NetworkAdapter)) {
        return 'Computer is not connected to the Internet'
    }
}

function Reset-State {
    Write-Log $INF "Cleaning up '$PATH_APP_DIR'"
    Remove-Item -Force -ErrorAction SilentlyContinue -Recurse $PATH_APP_DIR
    $HOST.UI.RawUI.WindowTitle = $OLD_WINDOW_TITLE
    Write-Host ''
}

function Exit-Script {
    Reset-State
    $FORM.Close()
}


function Open-InBrowser {
    param([String][Parameter(Position = 0, Mandatory = $True)]$URL)

    Write-Log $INF "Opening URL in the default browser: $URL"

    try {
        [System.Diagnostics.Process]::Start($URL)
    } catch [Exception] {
        Write-ExceptionLog $_ 'Could not open the URL'
    }
}
