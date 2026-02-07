function Reset-State {
    param(
        [Switch]$Update
    )

    if (-not $Update) {
        Remove-File "$PATH_TEMP_DIR\qiiwexc.ps1" -Silent
    }

    $HOST.UI.RawUI.WindowTitle = $ORIGINAL_WINDOW_TITLE
    Write-Host ''
}

function Exit-App {
    param(
        [Switch]$Update
    )

    Write-LogInfo 'Exiting the app...'
    Reset-State -Update:$Update
    $FORM.Close()
}
